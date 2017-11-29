module TheTradeUser
  extend ActiveSupport::Concern

  included do
    belongs_to :buyer, class_name: '::Buyer', optional: true
    belongs_to :provider, inverse_of: :users, autosave: true, optional: true

    has_many :cart_items, dependent: :nullify
    has_many :orders, dependent: :nullify
  end


end

