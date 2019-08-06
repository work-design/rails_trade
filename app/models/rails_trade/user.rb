module RailsTrade::User
  extend ActiveSupport::Concern

  included do
    has_many :carts, dependent: :destroy
  end

end

