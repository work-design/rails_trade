class PaymentReference < ApplicationRecord
  belongs_to :payment_method, inverse_of: :payment_references

  before_save :prevent_duplicate
  after_initialize if: :new_record? do |t|
    self.buyer_id = self.user&.buyer_id if self.buyer_id.nil?
  end

  def prevent_duplicate
    if PaymentReference.exists?(payment_method_id: self.payment_method_id, buyer_id: self.buyer_id)
      throw(:abort)
    end
  end

end unless RailsTrade.config.disabled_models.include?('PaymentReference')
