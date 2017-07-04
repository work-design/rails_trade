module BuyerAble
  extend ActiveSupport::Concern

  included do
    has_many :payment_references, as: :buyer, dependent: :destroy, autosave: true
    has_many :payment_methods, through: :payment_references, autosave: true
    has_many :orders, as: :buyer
  end

  def name_detail
    "#{name} (#{id})"
  end

end

# required attributes
# name
