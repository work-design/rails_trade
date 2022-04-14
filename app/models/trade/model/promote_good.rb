module Trade
  module Model::PromoteGood
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :state, :string, default: 'unused'
      attribute :status, :string, default: 'available'
      attribute :effect_at, :datetime, default: -> { Time.current }
      attribute :expire_at, :datetime
      attribute :trade_promotes_count, :integer, default: 0

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true

      belongs_to :promote
      belongs_to :good, polymorphic: true, optional: true
      has_many :cart_promotes
      has_many :item_promotes

      scope :verified, -> { where(status: ['default', 'available']) }
      scope :valid, -> { t = Time.current; verified.default_where('effect_at-lte': t, 'expire_at-gte': t) }
      scope :available, -> { t = Time.current; unused.default_where('expire_at-gte': t, 'effect_at-lte': t) }

      enum status: {
        available: 'available',  # 可选
        unavailable: 'unavailable',  # 不可选
      }, _default: 'available'

      enum state: {
        unused: 'unused',
        used: 'used',
        expired: 'expired'
      }

      validates :effect_at, presence: true
      validates :expire_at, presence: true
      validates :promote_id, uniqueness: { scope: [:good_type, :good_id] }

      before_validation :sync_from_promote, if: -> { promote.present? && promote_id_changed? }
    end

    def sync_from_promote
      self.organ_id = promote.organ_id
    end

    def promote_name
      promote.name
    end

  end
end
