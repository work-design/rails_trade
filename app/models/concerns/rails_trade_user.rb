# should define methods: buyer
module RailsTradeUser
  extend ActiveSupport::Concern

  included do
    attribute :buyer_type, :string, default: self.name
  end

end

