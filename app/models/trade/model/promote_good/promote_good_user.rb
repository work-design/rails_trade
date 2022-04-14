module Trade
  module Model::PromoteGood::PromoteGoodUser
    extend ActiveSupport::Concern

    included do
      attribute :state, :string, default: 'unused'

      enum state: {
        unused: 'unused',
        used: 'used',
        expired: 'expired'
      }
    end

  end
end
