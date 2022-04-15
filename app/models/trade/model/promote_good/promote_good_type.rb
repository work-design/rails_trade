module Trade
  module Model::PromoteGood::PromoteGoodType
    extend ActiveSupport::Concern

    included do
      attribute :blacklists_count, :integer, default: 0

      has_many :blacklists, ->(o){ where(good_type: o.good_type, status: 'unavailable') }, class_name: self.name, primary_key: :promote_id, foreign_key: :promote_id
      belongs_to :master,  ->(o){ where(good_type: o.good_type, good_id: nil, status: 'available') }, class_name: self.name, foreign_key: :promote_id, primary_key: :promote_id, counter_cache: :blacklists_count, optional: true
    end

  end
end
