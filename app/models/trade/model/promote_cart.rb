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
      belongs_to :cart  # todo remove
      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :user, class_name: 'Auth::User'
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :promote_good, optional: true
      has_many :trade_promotes, dependent: :nullify

      enum state: {
        unused: 'unused',
        used: 'used',
        expired: 'expired'
      }

      scope :available, -> { t = Time.current; unused.default_where('expire_at-gte': t, 'effect_at-lte': t) }

      validates :effect_at, presence: true
      validates :expire_at, presence: true

      before_validation do
        self.promote = self.promote_good.promote
      end
    end

  end
end
