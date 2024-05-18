module Trade
  module Model::PromoteGood::PromoteGoodCard
    extend ActiveSupport::Concern

    included do
      belongs_to :card_template
      belongs_to :card, optional: true
    end

  end
end
