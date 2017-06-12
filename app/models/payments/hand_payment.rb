class HandPayment < Payment

  def save_detail!(params)
    self.company_id = order.company_id
    self.notified_at = Time.now
    self.total_amount = params[:total_amount]
    self.order_uuid = order.uuid
    self.state = 'completed'
    self.buyer_email = order.contact&.email
    self.buyer_identifier = order.contact_id
    self.user_id = params[:user_id] if params[:user_id].present?
    self.employee_id = params[:employee_id] if params[:employee_id].present?
    self.save!
  end

end