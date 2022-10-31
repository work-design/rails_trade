module Trade
  module Model::AdditionCharge
    extend ActiveSupport::Concern
    include Inner::Charge

    included do
      belongs_to :addition
    end

    def minors
      addition.addition_charges.default_where('min-lt': self.min).order(min: :asc)
    end

  end
end
