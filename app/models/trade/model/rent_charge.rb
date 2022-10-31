module Trade
  module Model::RentCharge
    include Inner::Charge
    extend ActiveSupport::Concern

    included do
      belongs_to :rentable, polymorphic: true
    end

  end
end
