class BankPayment < Payment
  #validates :buyer_name, presence: true
  #validates :buyer_identifier, presence: true

  def assign_detail(params)
    self.notified_at = Time.now
    self.total_amount = params[:total_amount]
    self.order_uuid = order.uuid
    self.buyer_email = order.contact&.email
    self.buyer_identifier = order.contact_id
  end

end
