module Trade
  module Model::Payment
    extend ActiveSupport::Concern

    included do
      attribute :type, :string, default: 'Trade::HandPayment'
      attribute :payment_uuid, :string
      attribute :pay_status, :string, comment: '记录来自服务商的状态'
      attribute :currency, :string, default: RailsTrade.config.default_currency
      attribute :total_amount, :decimal
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
      attribute :verified, :boolean, default: false, comment: '是否已确认收款'
      attribute :lock_version, :integer
      attribute :extra, :json, default: {}
      attribute :extra_params, :json, default: {}
      attribute :payment_orders_count, :integer, default: 0
      attribute :refunds_count, :integer, default: 0

      enum state: {
        init: 'init',
        proof_uploaded: 'proof_uploaded',
        part_checked: 'part_checked',
        all_checked: 'all_checked',
        adjust_checked: 'adjust_checked',
        abusive_checked: 'abusive_checked',
        refunded: 'refunded'
      }, _default: 'init', _prefix: true

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :operator, polymorphic: true, optional: true

      belongs_to :payment_method, optional: true
      has_many :payment_orders, inverse_of: :payment, dependent: :destroy
      has_many :orders, through: :payment_orders, inverse_of: :payments
      accepts_nested_attributes_for :payment_orders
      has_many :refunds

      has_one_attached :proof

      after_initialize :init_uuid, if: -> { new_record? && (user_id.present? || payment_orders.present?) }
      before_save :compute_amount, if: -> { (changes.keys & ['total_amount', 'fee_amount', 'refunded_amount']).present? }
      before_create :analyze_payment_method
      before_save :sync_state_proof_uploaded, if: -> { attachment_changes['proof'].is_a?(ActiveStorage::Attached::Changes::CreateOne) }
      #after_save_commit :send_notice, if: -> { all_checked? && saved_change_to_state? }
      after_save_commit :send_verify_notice, if: -> { verified? && saved_change_to_verified? }
    end

    def sync_state_proof_uploaded
      self.state = 'proof_uploaded'
    end

    def init_uuid
      self.payment_uuid ||= UidHelper.nsec_uuid('PAY')
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
      total_amount.to_d - payment_orders.sum(:payment_amount)
    end

    def compute_amount
      self.income_amount = self.total_amount.to_d - self.fee_amount.to_d - self.refunded_amount.to_d
      self.check_state
    end

    def compute_checked_amount
      self.payment_orders.select(&->(o){ o.confirmed? }).sum(&:payment_amount)
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
      order = Order.where(organ_id: organ_id).find order_id
      payment_order = self.payment_orders.build(order_id: order.id)
      payment_order.order_amount = order.unreceived_amount
      save
    end

    def check_state
      if checked_amount == total_amount
        self.state = 'all_checked'
      elsif checked_amount == 0
        self.state = 'init'
      elsif checked_amount < total_amount
        self.state = 'part_checked'
      elsif checked_amount > total_amount
        self.state = 'adjust_checked'
      else
        self.state = 'abusive_checked'
      end
    end

    def confirm(params = {})
      self.assign_detail params
      payment_orders.each do |payment_order|
        payment_order.state = 'confirmed'
        self.checked_amount += payment_order.payment_amount.to_d
      end
    end

    def confirm!(params = {})
      self.confirm(params)
      self.save
    end

    def send_notice
      broadcast_action_to(
        self,
        action: :update,
        target: 'order_result',
        partial: 'success',
        locals: { organ_id: organ_id, payment: self }
      )
    end

    def send_verify_notice
      broadcast_action_to(
        self,
        action: :update,
        target: 'order_result',
        partial: 'success',
        locals: { organ_id: organ_id, payment: self }
      )
    end

    class_methods do

      def total_amount_step
        0.1.to_d.power(self.columns_hash['total_amount'].scale || self.columns_hash['total_amount'].limit || 2)
      end

    end

  end
end
