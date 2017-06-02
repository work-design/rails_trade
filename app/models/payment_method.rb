class PaymentMethod < ApplicationRecord
  has_many :payments, dependent: :nullify
  has_many :payment_references, dependent: :destroy
  has_many :buyers, through: :payment_references


  def account_types
    PaymentReference.pluck(:account_type).uniq
  end


  def related_orders


  end

end



