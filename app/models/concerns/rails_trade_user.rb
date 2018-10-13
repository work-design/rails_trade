# should define methods: buyer & buyer_id
module RailsTradeUser
  extend ActiveSupport::Concern

  included do
    attribute :provider_id, :integer
    attribute :buyer_type, :string, default: self.name

    belongs_to :provider, inverse_of: :users, autosave: true, optional: true

    has_many :addresses, foreign_key: :user_id, dependent: :nullify
    has_many :cart_items, foreign_key: :user_id, dependent: :nullify
    has_many :orders, foreign_key: :user_id, dependent: :nullify

  end

end

