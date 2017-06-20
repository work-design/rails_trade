class Refund < ApplicationRecord
  belongs_to :order

  after_initialize if: -> { new_record? } do
    self.refund_uuid = new_batch_no
    self.state = :init
  end

  enum state: [
    :init,
    :completed,
    :failed
  ]
  validate :valid_total_amount

  def new_batch_no
    Alipay::Utils.generate_batch_no
  end

  # 谨慎更新批次号 by xujian
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

    return true
  end

  def refund_failed!(params = {})
    self.state = 'failed'
    self.class.transaction do
      self.origin&.online_refund_failed!(self, params)
      self.save!
    end
    return true
  end

  def valid_total_amount
    if self.new_record? && amount > refunded_payment.total_amount
      self.errors.add :amount, 'more then order received amount!'
    end
  end

end
