module Trade
  module Model::Payment
    extend ActiveSupport::Concern

    included do
      attribute :type, :string, default: 'Trade::HandPayment'
      attribute :payment_uuid, :string
      attribute :state, :string, default: 'init', index: true
      attribute :pay_status, :string
      attribute :currency, :string, default: RailsTrade.config.default_currency
      attribute :total_amount, :decimal, default: 0
      attribute :checked_amount, :decimal, default: 0
      attribute :adjust_amount, :decimal, default: 0
      attribute :fee_amount, :decimal, default: 0
      attribute :refunded_amount, :decimal, default: 0
      attribute :income_amount, :decimal, comment: '实际到账'
      attribute :notify_type, :string
      attribute :notified_at, :datetime
      attribute :seller_identifier, :string
      attribute :buyer_identifier, :string
      attribute :buyer_name, :string
      attribute :buyer_bank, :string
      attribute :comment, :string
      attribute :verified, :boolean, default: true
      attribute :lock_version, :integer
      attribute :extra, :json, default: {}

      enum state: {
        init: 'init',
        part_checked: 'part_checked',
        all_checked: 'all_checked',
        adjust_checked: 'adjust_checked',
        abusive_checked: 'abusive_checked',
        refunded: 'refunded'
      }, _default: 'init'

      belongs_to :organ, optional: true
      belongs_to :user, optional: true
      belongs_to :payment_method, optional: true
      has_many :payment_orders, inverse_of: :payment, dependent: :destroy_async, validate: false # 因为 order 会 save, 避免重复 save
      has_many :orders, through: :payment_orders, inverse_of: :payments
      accepts_nested_attributes_for :payment_orders

      default_scope -> { order(created_at: :desc) }

      validates :payment_uuid, presence: true, uniqueness: { scope: :type }

      before_validation do
        self.payment_uuid = UidHelper.nsec_uuid('PAY') if payment_uuid.blank?
      end
      before_save :compute_amount, if: -> { (changes.keys & ['total_amount', 'fee_amount']).present? }
      before_create :analyze_payment_method

      has_one_attached :proof
    end

    def analyze_payment_method
      if self.buyer_name.present? || self.buyer_identifier.present?
        pm = PaymentMethod.find_or_initialize_by(account_name: self.buyer_name.to_s, account_num: self.buyer_identifier.to_s)
        pm.bank = self.buyer_bank
        self.payment_method = pm

        pm.save
      end
    end

    def unchecked_amount
      total_amount.to_d - payment_orders.sum(:check_amount)
    end

    def compute_amount
      self.income_amount = self.total_amount - self.fee_amount
      self.check_state
    end

    def compute_checked_amount
      self.payment_orders.select(&->(o){ o.confirmed? }).sum(&:check_amount)
    end

    def pending_orders
      if self.payment_method
        user_ids = self.payment_method.payment_references.pluck(:user_id)
        Order.where.not(id: self.payment_orders.pluck(:order_id)).where(user_id: user_ids, payment_status: ['unpaid', 'part_paid'], state: 'active')
      else
        Order.none
      end
    end

    def analyze_adjust_amount
      self.adjust_amount = self.checked_amount - self.total_amount
      self.state = 'all_checked'
      self.save
    end

    def check_order(order_id)
      order = Order.find order_id
      payment_order = self.payment_orders.build(order_id: order.id)
      payment_order.check_amount = order.unreceived_amount
      payment_order.save

      payment_order
    end

    def check_state
      if self.checked_amount == self.total_amount
        self.state = 'all_checked'
      elsif self.checked_amount == 0
        self.state = 'init'
      elsif self.checked_amount < self.total_amount
        self.state = 'part_checked'
      elsif self.checked_amount > self.total_amount
        self.state = 'adjust_checked'
      else
        self.state = 'abusive_checked'
      end
    end

    def confirm!(params = {})
      self.assign_detail params
      self.class.transaction do
        self.save!
        payment_orders.each(&:confirm!)
      end
      send_notice
    end

    def send_notice
      broadcast_action_to self, action: :update, target: 'order_result', partial: 'factory/buy/payments/success', locals: { organ_id: organ_id }
    end

    class_methods do

      def total_amount_step
        0.1.to_d.power(self.columns_hash['total_amount'].scale || self.columns_hash['total_amount'].limit)
      end

    end

  end
end
