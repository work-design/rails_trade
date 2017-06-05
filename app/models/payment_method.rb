class PaymentMethod < ApplicationRecord
  has_many :payments, dependent: :nullify
  has_many :payment_references, dependent: :destroy, autosave: true, inverse_of: :payment_method
  has_many :buyers, through: :payment_references, autosave: true

  default_scope -> { where(verified: true) }

  def account_types
    PaymentReference.pluck(:account_type).uniq
  end

  def detect_repetition
    if self.persisted?
      self.class.where.not(id: self.id).exists?(account_name: self.account_name, account_num: self.account_num)
    else
      self.class.exists?(account_name: self.account_name, account_num: self.account_num)
    end
  end

  def related_orders


  end

end



