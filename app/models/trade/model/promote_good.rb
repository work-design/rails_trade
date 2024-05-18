module Trade
  module Model::PromoteGood
    extend ActiveSupport::Concern

    included do
      attribute :status, :string, default: 'available'
      attribute :effect_at, :datetime, default: -> { Time.current }
      attribute :expire_at, :datetime
      attribute :item_promotes_count, :integer, default: 0
      attribute :identity, :string
      attribute :use_limit, :integer, default: 1
      attribute :over_limit, :boolean, as: 'item_promotes_count >= use_limit', virtual: true
      attribute :blacklists_count, :integer, default: 0

      enum status: {
        available: 'available',  # 可选
        unavailable: 'unavailable',  # 不可选
      }, _default: 'available'

      enum aim: {
        use: 'use',
        rent: 'rent',
        invest: 'invest'
      }, _default: 'use'

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :user, class_name: 'Auth::User', counter_cache: :promote_goods_count, optional: true
      belongs_to :member, class_name: 'Org::Member', counter_cache: :promote_goods_count, optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :card_template
      belongs_to :card, optional: true


      has_many :blacklists, ->(o) { where(good_type: o.good_type, status: 'unavailable') }, class_name: self.name, primary_key: :promote_id, foreign_key: :promote_id
      belongs_to :master,  ->(o) { where(good_type: o.good_type, good_id: nil, status: 'available') }, class_name: self.name, foreign_key: :promote_id, primary_key: :promote_id, counter_cache: :blacklists_count, optional: true


      belongs_to :promote
      belongs_to :good, polymorphic: true, optional: true

      has_many :item_promotes
      has_many :promote_good_types, ->(o) { where(aim: o.aim, status: 'available') }, primary_key: :good_type, foreign_key: :good_type


      scope :verified, -> { where(status: ['available']) }
      scope :effective, -> { t = Time.current; verified.where(over_limit: [false, nil]).default_where('effect_at-lte': t, 'expire_at-gte': t) }

      validates :effect_at, presence: true
      validates :expire_at, presence: true
      validates :promote_id, uniqueness: { scope: [:type, :good_type, :good_id, :user_id, :member_id] }

      before_validation :sync_from_promote, if: -> { promote.present? && promote_id_changed? }
      before_validation :sync_user, if: -> { member_id_changed? }

      #after_save_commit :compute_over_limit, if: -> {}
    end

    def expired?
      expire_at < Time.current
    end

    def sync_from_promote
      self.organ_id = promote.organ_id
    end

    def promote_name
      promote.name
    end

  end
end
