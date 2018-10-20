# should define methods: buyer
module RailsTradeUser
  extend ActiveSupport::Concern

  included do
    attribute :buyer_type, :string, default: self.name
    attribute :provider_id, :integer
    belongs_to :provider, inverse_of: :users, autosave: true, optional: true
  end

end

