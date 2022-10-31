module Trade
  module Model::RentCharge
    include Model::Charge
    extend ActiveSupport::Concern

    included do
      belongs_to :rentable, polymorphic: true
    end

  end
end
