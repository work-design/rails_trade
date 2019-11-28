module RailsTrade::Payment
  extend ActiveSupport::Concern
  included do
    attribute :type, :string, default: 'HandPayment'
    attribute :payment_uuid, :string
    attribute :state, :string, default: 'init', index: true
    attribute :pay_status, :string
    attribute :currency, :string, default: RailsTrade.config.default_currency
    attribute :adjust_amount, :decimal, precision: 10, scale: 2, default: 0
    attribute :total_amount, :decimal, precision: 10, scale: 2, default: 0
    attribute :fee_amount, :decimal, precision: 10, scale: 2, default: 0
    attribute :checked_amount, :decimal, precision: 10, scale: 2, default: 0
    attribute :income_amount, precision: 10, scale: 2
    attribute :notify_type, :string, limit: 255
    attribute :notified_at, :datetime
    attribute :seller_identifier, :string
    attribute :buyer_identifier, :string
    attribute :buyer_name, :string
    attribute :buyer_bank, :string
    attribute :comment, :string
    attribute :verified, :boolean, default: true
    attribute :lock_version, :integer
    
    belongs_to :organ, optional: true
    belongs_to :user
    belongs_to :payment_method, optional: true
    belongs_to :creator, optional: true
    has_many :payment_orders, inverse_of: :payment, dependent: :destroy
    has_many :orders, through: :payment_orders, inverse_of: :payments
  
    default_scope -> { order(created_at: :desc) }
  
    validates :payment_uuid, presence: true, uniqueness: { scope: :type }
  
    before_validation do
      self.payment_uuid = UidHelper.nsec_uuid('PAY') if payment_uuid.blank?
    end
    before_save :compute_amount
    after_create :analyze_payment_method
  
    has_one_attached :proof
  
    enum state: {
      init: 'init',
      part_checked: 'part_checked',
      all_checked: 'all_checked',
      adjust_checked: 'adjust_checked',
      abusive_checked: 'abusive_checked'
    }
  end

  def analyze_payment_method
    if self.buyer_name.present? || self.buyer_identifier.present?
      pm = PaymentMethod.find_or_initialize_by(account_name: self.buyer_name.to_s, account_num: self.buyer_identifier.to_s)
      pm.bank = self.buyer_bank
      self.payment_method = pm

      pm.save
      self.save
    end
  end

  def unchecked_amount
    total_amount.to_d - payment_orders.sum(:check_amount)
  end

  def compute_amount
    if income_amount.blank? && fee_amount.present?
      self.income_amount = self.total_amount - self.fee_amount
    end

    if fee_amount.blank? && income_amount.present?
      self.fee_amount = self.total_amount - self.income_amount
    end

    self.check_state
  end

  def compute_checked_amount
    self.payment_orders.where(state: :confirmed).sum(:check_amount)
  end

  def pending_orders
    if self.payment_method
      buyer_ids = self.payment_method.payment_references.pluck(:buyer_id)
      Order.where.not(id: self.payment_orders.pluck(:order_id)).where(buyer_id: buyer_ids, payment_status: ['unpaid', 'part_paid'], state: 'active')
    else
      Order.none
    end
  end

  def analyze_adjust_amount
    self.adjust_amount = self.checked_amount.to_d - self.total_amount.to_d
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

  def check_state!
    self.check_state
    self.save!
  end
  
  class_methods do
    
    def total_amount_step
      0.1.to_d.power(Payment.columns_hash['total_amount'].scale)
    end
    
  end

end
