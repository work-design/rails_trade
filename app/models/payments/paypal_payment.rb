class PaypalPayment < Payment
  PAYMENT =  PayPal::SDK::REST::DataTypes::Payment
  delegate :url_helpers, to: 'Rails.application.routes'
  attr_accessor :approve_url, :return_url, :cancel_url

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

  def create_payment
    _payment = PAYMENT.new(final_params)
    _payment.create
    self.payment_uuid = _payment.id
    self.total_amount = insured_total_amount[0].to_d
    self.order_amount = insured_total_amount[1].to_d


    if self.save
      self.approve_url = _payment.links.find{ |link| link.method == 'REDIRECT' }.try(:href)
    else
      errors.add :type, _payment.error['message']
    end
    _payment
  end

  def execute(params)
    return unless self.payment_uuid

    _payment = PAYMENT.find(self.payment_uuid)
    _payment.execute(payer_id: params[:PayerID])
    _payment
  end



end
