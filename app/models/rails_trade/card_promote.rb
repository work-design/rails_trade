module RailsVip::CardPromote
  extend ActiveSupport::Concern

  included do
    attribute :income_min, :decimal, precision: 10, scale: 2, default: 0
    attribute :income_max, :decimal, precision: 10, scale: 2, default: 99999999.99

    belongs_to :card_template
    belongs_to :promote
  end

end
