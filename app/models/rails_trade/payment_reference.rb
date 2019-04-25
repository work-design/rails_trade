module RailsTrade::PaymentReference
  extend ActiveSupport::Concern
  included do
    belongs_to :payment_method, inverse_of: :payment_references
    belongs_to :buyer, polymorphic: true
  
    before_save :prevent_duplicate
  end
  
  def prevent_duplicate
    if PaymentReference.exists?(payment_method_id: self.payment_method_id, buyer_id: self.buyer_id, buyer_type: self.buyer_type)
      throw(:abort)
    end
  end

end
