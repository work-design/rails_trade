module Trade
  module Ext::Financial
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :price, :decimal
      attribute :rentals_count, :integer, default: 0

      has_many :rentals, ->{ where(rentable: true) }
    end

  end
end
