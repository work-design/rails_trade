class Buyer < ApplicationRecord
  has_many :payment_references, dependent: :destroy, autosave: true, inverse_of: :buyer
  has_many :payment_methods, through: :payment_references, autosave: true
  has_many :orders

end


# :name, :string

