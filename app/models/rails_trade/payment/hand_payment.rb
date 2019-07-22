module RailsTrade::Payment::HandPayment
  extend ActiveSupport::Concern
  included do
    after_initialize if: :new_record? do
      self.payment_uuid = UidHelper.nsec_uuid('PAY') if payment_uuid.blank?
    end
  end
  
  def assign_detail(params)
    self.notified_at = Time.now
    self.total_amount = params[:total_amount]
  end

end
