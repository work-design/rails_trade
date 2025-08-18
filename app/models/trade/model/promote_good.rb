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

      enum :status, {
        available: 'available',  # 可选
        unavailable: 'unavailable',  # 不可选
      }, default: 'available'

      enum :aim, {
        use: 'use',
        rent: 'rent',
        invest: 'invest'
      }, default: 'use'

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :user, class_name: 'Auth::User', counter_cache: :promote_goods_count, optional: true
      belongs_to :member, class_name: 'Org::Member', counter_cache: :promote_goods_count, optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :card_template, optional: true
      belongs_to :card, optional: true
      belongs_to :promote
      belongs_to :taxon, optional: true
      belongs_to :good, polymorphic: true, optional: true
      belongs_to :master, ->(o){ where(good_id: nil, status: 'available', **o.master_filter) }, class_name: self.name, foreign_key: :promote_id, primary_key: :promote_id, counter_cache: :blacklists_count, optional: true

      has_many :blacklists, ->(o){ where(status: 'unavailable', **o.master_filter) }, class_name: self.name, primary_key: :promote_id, foreign_key: :promote_id
      has_many :item_promotes
      has_many :promote_good_types, ->(o) { where(aim: o.aim, status: 'available') }, primary_key: :good_type, foreign_key: :good_type

      scope :verified, -> { where(status: ['available']) }
      scope :effective, -> { t = Time.current; verified.where(over_limit: [false, nil]).default_where('effect_at-lte': t, 'expire_at-gte': t) }

      validates :effect_at, presence: true
      validates :expire_at, presence: true
      validates :promote_id, uniqueness: { scope: [:good_type, :good_id, :user_id, :member_id, :card_template_id, :card_id, :product_taxon_id, :part_id] }

      before_validation :sync_from_promote, if: -> { promote.present? && promote_id_changed? }
    end

    def master_filter
      {
        good_type: good_type
      }
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
