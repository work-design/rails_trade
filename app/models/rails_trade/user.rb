# should define methods: buyer
module RailsTrade::User
  extend ActiveSupport::Concern

  included do
    has_many :carts, dependent: :destroy
    has_many :orders, dependent: :nullify
  end

end

