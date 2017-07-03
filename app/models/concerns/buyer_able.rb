module BuyerAble
  extend ActiveSupport::Concern

  included do
    has_many :payment_references, as: :buyer, dependent: :destroy, autosave: true
    has_many :payment_methods, through: :payment_references, autosave: true
    has_many :orders, as: :buyer

    Order.belongs_to :buyer, polymorphic: true
    PaymentReference.belongs_to :buyer, polymorphic: true
  end

end

# required attributes
# name
