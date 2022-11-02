module Trade
  module Model::RentCharge
    extend ActiveSupport::Concern
    include Inner::Charge

    included do
      attribute :min, :integer, default: 0
      attribute :max, :integer, default: 2**31 - 1
      attribute :filter_min, :integer, default: 0
      attribute :filter_max, :integer, default: 2**31 - 1

      belongs_to :rentable, polymorphic: true
    end

    def minors
      rentable.rent_charges.default_where('min-lt': self.min).order(min: :asc)
    end

  end
end
