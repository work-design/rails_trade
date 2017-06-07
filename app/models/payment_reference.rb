class PaymentReference < ApplicationRecord
  belongs_to :payment_method, autosave: true, inverse_of: :payment_references
  belongs_to :buyer, autosave: true, inverse_of: :payment_references

  before_save :prevent_duplicate

  def prevent_duplicate
    if PaymentReference.exists?(payment_method_id: self.payment_method_id, buyer_id: self.buyer_id)
      throw(:abort)
    end
  end

end
