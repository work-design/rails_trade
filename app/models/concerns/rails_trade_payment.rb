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
    self.payment_orders.sum(:check_amount)
  end

  def pending_payments
    Payment.where.not(id: self.payment_orders.pluck(:payment_id)).where(payment_method_id: self.buyer.payment_method_ids, state: ['init', 'part_checked'])
  end

  def exists_payments
    Payment.where.not(id: self.payment_orders.pluck(:payment_id)).exists?(payment_method_id: self.buyer.payment_method_ids, state: ['init', 'part_checked'])
  end

  def confirm_paid!
    self.order_items.each(&:confirm_paid!)
  end

  def confirm_part_paid!
    self.order_items.each(&:confirm_part_paid!)
  end

  def change_to_paid!(type: nil, params: {})
    if self.payment_status == 'all_paid'
      return self
    end

    if self.amount == 0
      self.received_amount = self.amount
      self.check_state!
      return self
    end

    if type
      self.save_detail(type, params)
    elsif self.payment_type.present?
      begin
        self.send self.payment_type + '_result'
      rescue NoMethodError
        self
      end
    end
  end

  def save_detail(type, params)
    payment = self.payments.build(type: type)
    payment.assign_detail params

    payment_order = self.payment_orders.find { |i| i.id.nil? }
    payment_order.check_amount = payment.total_amount
    payment_order.confirm

    payment.save!
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
    self.check_state
    self.save!
  end

end
