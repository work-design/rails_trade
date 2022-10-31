module Trade
  module Ext::Rentable
    extend ActiveSupport::Concern

    included do
      has_many :rent_charges, as: :rentable
    end

  end
end

