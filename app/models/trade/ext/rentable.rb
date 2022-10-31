module Trade
  module Ext::Rentable
    extend ActiveSupport::Concern

    included do
      has_many :rent_charges, class_name: 'Trade::RentCharge', as: :rentable
    end

  end
end

