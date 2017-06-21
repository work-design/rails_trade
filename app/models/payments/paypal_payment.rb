class PaypalPayment < Payment


  def save_detail!(params)
    self.company_id = order.company_id
    self.order_uuid = order.uuid
    self.notified_at = Time.now
    self.state = 'completed'
    self.buyer_email = order.contact&.email
    self.buyer_identifier = order.contact_id
    self.seller_identifier = params[:sale_id]
    self.user_id = params[:user_id] if params[:user_id].present?
    self.save!
  end





end
