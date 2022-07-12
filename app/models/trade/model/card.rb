module Trade
  module Model::Card
    extend ActiveSupport::Concern

    included do
      attribute :lock_version, :integer
      attribute :card_uuid, :string
      attribute :effect_at, :datetime
      attribute :expire_at, :datetime
      attribute :temporary, :boolean, default: false, comment: '在购物车勾选临时生效'

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true

      belongs_to :card_template, counter_cache: true
      belongs_to :trade_item, optional: true # 记录开通的 trade_item
      belongs_to :client, optional: true
      belongs_to :agency, optional: true

      has_many :card_purchases, dependent: :nullify
      has_many :card_logs, dependent: :destroy_async
      has_many :card_promotes, ->(o){ default_where('income_min-lte': o.income_amount, 'income_max-gt': o.income_amount) }, foreign_key: :card_template_id, primary_key: :card_template_id
      has_many :promotes, through: :card_promotes
      has_many :trade_items, ->(o) { where(organ_id: o.organ_id, member_id: o.member_id).carting }, foreign_key: :user_id, primary_key: :user_id
      has_many :plan_attenders, ->(o){ where(attender_type: o.client_type) }, foreign_key: :attender_id, primary_key: :client_id

      scope :effective, ->{ t = Time.current; default_where('expire_at-gte': t, 'effect_at-lte': t) }
      scope :temporary, ->{ where(temporary: true) }
      scope :formal, ->{ where.not(temporary: true) }

      before_validation :init_uuid, if: -> { card_uuid.blank? }
      before_validation :sync_from_card_template, if: -> { card_template_id.present? }
      after_commit :recompute_price, on: [:create, :destroy]
    end

    def init_uuid
      self.card_uuid = UidHelper.nsec_uuid('CARD')
    end

    def sync_from_card_template
      return unless card_template
      self.organ_id ||= card_template.organ_id
      self.effect_at ||= Time.current
    end

    def recompute_price
      trade_items.each(&:compute_price!)
    end

  end
end
