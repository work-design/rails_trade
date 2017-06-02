module ThePayable
  extend ActiveSupport::Concern

  included do
    has_many :payment_references, as: :account, dependent: :destroy
    has_many :payment_methods, through: :payment_references

    PaymentMethod.has_many :accounts, through: :payment_references, source_type: 'Company'
  end


end
