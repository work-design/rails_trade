module Trade
  module Model::PromoteCart
    extend ActiveSupport::Concern

    included do
      attribute :state, :string, default: 'unused'
      attribute :status, :string, default: 'available'
      attribute :effect_at, :datetime
      attribute :expire_at, :datetime
      attribute :trade_promotes_count, :integer, default: 0

      belongs_to :promote
      belongs_to :cart
      belongs_to :promote_good, optional: true
      has_many :trade_promotes, dependent: :nullify

      enum state: {
        unused: 'unused',
        used: 'used'
      }

      scope :valid, -> { t = Time.current; unused.default_where('expire_at-gte': t, 'effect_at-lte': t) }

      before_validation do
        self.promote = self.promote_good.promote
      end
    end

  end
end
