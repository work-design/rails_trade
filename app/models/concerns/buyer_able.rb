module BuyerAble
  extend ActiveSupport::Concern

  included do
    has_many :payment_references, foreign_key: :buyer_id, dependent: :destroy, autosave: true, inverse_of: :buyer
    has_many :payment_methods, through: :payment_references, autosave: true
    has_many :orders

    Order.belongs_to :buyer, class_name: name, foreign_key: :buyer_id
    PaymentReference.belongs_to :buyer, class_name: name, foreign_key: :buyer_id, inverse_of: :payment_references
  end

end

# required attributes
# name
