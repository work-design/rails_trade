class HandPayment < Payment

  after_initialize if: :new_record? do |lb|
    self.payment_uuid = UidHelper.nsec_uuid('PAY')
  end

  def assign_detail(params)
    self.notified_at = Time.now
    self.total_amount = params[:total_amount]
  end

end
