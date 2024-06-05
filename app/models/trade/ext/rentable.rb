module Trade
  module Ext::Rentable
    extend ActiveSupport::Concern

    included do
      attribute :rent_charges_count, :integer

      enum :rent_unit, {
        seconds: 'seconds',
        minutes: 'minutes',
        hours: 'hours',
        days: 'days',
        weeks: 'weeks',
        months: 'months',
        years: 'years'
      }, default: 'hours'

      has_many :rent_charges, class_name: 'Trade::RentCharge', as: :rentable
    end

  end
end
