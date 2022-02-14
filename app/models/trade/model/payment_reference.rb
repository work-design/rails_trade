module Trade
  module Model::PaymentReference
    extend ActiveSupport::Concern

    included do
      attribute :state, :string

      belongs_to :payment_method, inverse_of: :payment_references
      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true

      before_save :prevent_duplicate
    end

    def prevent_duplicate
      if PaymentReference.exists?(payment_method_id: self.payment_method_id, cart_id: self.cart_id)
        throw(:abort)
      end
    end

  end
end
