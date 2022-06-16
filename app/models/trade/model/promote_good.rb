module Trade
  module Model::PromoteGood
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :status, :string, default: 'available'
      attribute :effect_at, :datetime, default: -> { Time.current }
      attribute :expire_at, :datetime
      attribute :item_promotes_count, :integer, default: 0
      attribute :identity, :string
      attribute :aim, :string
      attribute :use_limit, :integer
      attribute :over_limit, :boolean, default: false

      enum status: {
        available: 'available',  # 可选
        unavailable: 'unavailable',  # 不可选
      }, _default: 'available'

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :user, class_name: 'Auth::User', counter_cache: true, optional: true
      belongs_to :member, class_name: 'Org::Member', counter_cache: true, optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true

      belongs_to :promote
      belongs_to :good, polymorphic: true, optional: true

      has_many :item_promotes

      scope :verified, -> { where(status: ['available']) }
      scope :effective, -> { t = Time.current; verified.default_where('effect_at-lte': t, 'expire_at-gte': t) }

      validates :effect_at, presence: true
      validates :expire_at, presence: true
      validates :promote_id, uniqueness: { scope: [:type, :good_type, :good_id, :user_id, :member_id] }

      before_validation :sync_from_promote, if: -> { promote.present? && promote_id_changed? }
      before_validation :sync_user, if: -> { member_id_changed? }
      after_save_commit :compute_over_limit, if: -> {}
    end

    def expired?
      expire_at < Time.current
    end

    def sync_from_promote
      self.organ_id = promote.organ_id
    end

    def sync_user
      self.user = self.member&.user
    end

    def promote_name
      promote.name
    end

  end
end
