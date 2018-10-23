# payment_id
# payment_type
# amount
# received_amount
module RailsTradePayment

  def can_pay?
    self.payment_type.present? && self.payment_status != 'all_paid'
  end

  def unreceived_amount
    self.amount.to_d - self.received_amount.to_d
  end

  def init_received_amount
    self.payment_orders.confirmed.sum(:check_amount)
  end

  def pending_payments
    Payment.where.not(id: self.payment_orders.pluck(:payment_id)).where(payment_method_id: self.buyer.payment_method_ids, state: ['init', 'part_checked'])
  end

  def exists_payments
    Payment.where.not(id: self.payment_orders.pluck(:payment_id)).exists?(payment_method_id: self.buyer.payment_method_ids, state: ['init', 'part_checked'])
  end

  def confirm_paid!
    self.order_items.each(&:confirm_paid!)
    notic_client
  end

  def confirm_part_paid!
    self.order_items.each(&:confirm_part_paid!)
  end

  def change_to_paid!(type:, payment_uuid:, params: {})
    payment = self.payments.find_by(type: type, payment_uuid: payment_uuid)

    if payment
      self.check_state!
      payment
    else
      payment = self.payments.build(type: type, payment_uuid: payment_uuid)
      payment.assign_detail params

      payment_order = self.payment_orders.find { |i| i.id.nil? }
      payment_order.check_amount = payment.total_amount
      payment_order.confirm

      payment.save!
      self.save!
      payment
    end
  end

  def payment_result(payment_kind: payment_type)
    if self.payment_status == 'all_paid'
      return self
    end

    if self.amount == 0
      self.received_amount = self.amount
      self.check_state!
    end

    if payment_kind.present?
      begin
        self.send payment_kind.to_s + '_result'
      rescue NoMethodError
        self
      end
    end

    self
  end

  def loop_payment_result(payment_kind: payment_type, max_times: 10)
    times = 0

    while self.payment_status != 'all_paid' do
      self.payment_result(payment_kind: payment_kind)
      times += 1
      break if times >= max_times
    end

    self
  end

  def check_state
    if self.received_amount.to_d >= self.amount
      self.payment_status = 'all_paid'
      self.confirm_paid!
    elsif self.received_amount.to_d > 0 && self.received_amount.to_d < self.amount
      self.payment_status = 'part_paid'
      self.confirm_part_paid!
    elsif self.received_amount.to_d <= 0
      self.payment_status = 'unpaid'
    end
  end

  def check_state!
    self.received_amount = init_received_amount
    self.check_state
    self.save!
  end

end
