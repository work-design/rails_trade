module Trade
  module Model::PromoteGood::PromoteGoodCard
    extend ActiveSupport::Concern

    included do
      belongs_to :card_template
    end

  end
end
