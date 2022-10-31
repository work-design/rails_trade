module Trade
  module Model::RentCharge
    extend ActiveSupport::Concern
    include Inner::Charge

    included do
      belongs_to :rentable, polymorphic: true
    end

  end
end
