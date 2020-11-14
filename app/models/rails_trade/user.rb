module RailsTrade::User
  extend ActiveSupport::Concern

  included do
    has_one :total_cart
    has_many :carts, dependent: :destroy
    has_many :orders, dependent: :destroy
    has_many :trade_items, dependent: :destroy
  end

end
