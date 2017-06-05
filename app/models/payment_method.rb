class PaymentMethod < ApplicationRecord
  has_many :payments, dependent: :nullify
  has_many :payment_references, dependent: :destroy, autosave: true, inverse_of: :payment_method
  has_many :buyers, through: :payment_references, autosave: true


  def account_types
    PaymentReference.pluck(:account_type).uniq
  end


  def related_orders


  end

end



