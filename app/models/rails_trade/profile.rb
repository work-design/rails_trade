module RailsVip::Profile
  extend ActiveSupport::Concern

  included do
    has_many :cards, as: :client
  end

end
