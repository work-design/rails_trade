class Refund < ApplicationRecord
  attribute :currency, :string, default: 'USD'

  belongs_to :user, optional: true
  belongs_to :order, optional: true
  belongs_to :payment

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
  def renew_refund_uuid
    if self.can_renew_refund_uuid?
      self.update(refund_uuid: new_batch_no)
    end
  end

  def can_renew_refund_uuid?
    false
  end

  def start_refund!
    self.origin&.online_refund_start!(self)
  end

  def do_refund!
    if self.state != 'completed'
      self.state = 'completed'
      self.refunded_at = Time.now

      self.class.transaction do
        self.origin&.online_refund_done!(self)
        self.save!
      end
    end

    true
  end

  def refund_failed!(params = {})
    self.state = 'failed'
    self.class.transaction do
      self.origin&.online_refund_failed!(self, params)
      self.save!
    end

    true
  end

  def valid_total_amount
    if self.new_record? && total_amount > payment.total_amount
      self.errors.add :total_amount, 'more then order received amount!'
    end
  end


  before_save :sync_amount

  def currency_symbol
    Money::Currency.new(self.currency).symbol
  end

  def do_refund(params = {})
    order.payment_status = 'refunded'
    order.received_amount -= self.total_amount

    self.state = 'completed'
    self.refunded_at = Time.now

    self.class.transaction do
      order.save!
      self.save!
    end
  end

  def operator

  end

  def sync_amount
    self.total_amount = self.order_amount.to_money.exchange_to(self.currency)
  end

end
