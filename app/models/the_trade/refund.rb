class Refund < ApplicationRecord
  attribute :currency, :string, default: 'USD'

  belongs_to :operator, polymorphic: true, optional: true
  belongs_to :order, inverse_of: :refunds, optional: true
  belongs_to :payment

  validates :payment_id, uniqueness: { scope: :order_id }

  after_initialize if: -> { new_record? } do
    self.refund_uuid = UidHelper.nsec_uuid('RD')
    self.state = :init
  end

  enum state: [
    :init,
    :completed,
    :failed
  ]

  #validate :valid_total_amount

  # 微信是同一个批次号未退款成功可重复申请
  # 支付宝批次号只能当天有效

  def valid_total_amount
    if self.new_record? && total_amount > payment.total_amount
      self.errors.add :total_amount, 'more then order received amount!'
    end
  end

  def currency_symbol
    Money::Currency.new(self.currency).symbol
  end

  def do_refund(params = {})
    order.payment_status = 'refunded'

    self.state = 'completed'
    self.refunded_at = Time.now

    self.class.transaction do
      order.save!
      self.save!
    end
  end

  def can_refund?
    self.init? && ['all_paid', 'part_paid', 'refunding'].include?(order.payment_status)
  end

end
