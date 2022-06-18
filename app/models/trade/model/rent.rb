module Trade
  module Model::Rent
    extend ActiveSupport::Concern

    included do
      belongs_to :rentable, polymorphic: true, counter_cache: true, optional: true
    end

  end
end
