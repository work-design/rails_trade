# should define methods: buyer
module RailsTrade::User
  extend ActiveSupport::Concern

  included do
    attribute :buyer_type, :string, default: self.name
  end

end

