class BankPayment < Payment
  validates :buyer_name, presence: true
  validates :buyer_identifier, presence: true

  def save_detail!(params)
    self.company_id = order.company_id
    self.notified_at = Time.now
    self.total_amount = params[:total_amount]
    self.order_amount = params[:order_amount]
    self.order_uuid = order.uuid
    self.state = 'completed'
    self.buyer_email = order.contact&.email
    self.buyer_identifier = order.contact_id
    self.user_id = params[:user_id] if params[:user_id].present?
    self.employee_id = params[:employee_id] if params[:employee_id].present?
    self.save!
  end

  def analyze_payment_method
    if self.buyer_name.present? && self.buyer_identifier.present?
      pm = PaymentMethod.find_or_initialize_by(account_name: self.buyer_name, account_num: self.buyer_identifier)
      pm.bank = self.buyer_bank
      self.payment_method = pm

      pm.save
      self.save
    end

  end

end