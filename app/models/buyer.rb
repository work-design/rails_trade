class Buyer < ApplicationRecord
  has_many :payment_references, dependent: :destroy
  has_many :payment_methods, through: :payment_references
  has_many :orders

end


# :name, :string

