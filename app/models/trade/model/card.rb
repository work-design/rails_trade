module Trade
  module Model::Card
    extend ActiveSupport::Concern
    include Inner::User

    included do
      attribute :card_uuid, :string
      attribute :effect_at, :datetime
      attribute :expire_at, :datetime
      attribute :temporary, :boolean, default: false, comment: '在购物车勾选临时生效'
      attribute :lock_version, :integer

      belongs_to :card_template, counter_cache: true
      belongs_to :agency, optional: true

      has_many :card_purchases
      has_many :card_promotes, ->(o){ default_where('income_min-lte': o.income_amount, 'income_max-gt': o.income_amount) }, foreign_key: :card_template_id, primary_key: :card_template_id
      has_many :promotes, through: :card_promotes
      has_many :items, ->(o) { where(organ_id: o.organ_id, member_id: o.member_id).carting }, foreign_key: :user_id, primary_key: :user_id
      has_many :plan_attenders, ->(o){ where(attender_type: o.client_type) }, foreign_key: :attender_id, primary_key: :client_id

      has_many :wallets, ->(o) { where(organ_id: o.organ_id, member_id: o.member_id) }, primary_key: :user_id, foreign_key: :user_id

      scope :effective, ->{ t = Time.current; where(expire_at: t...).or(where(expire_at: nil)).default_where('effect_at-lte': t) }
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

    def expired?(now = Time.current)
      return false if effect_at.present? && expire_at.blank?
      return true if self.expire_at.blank? || effect_at.blank?
      self.expire_at < now && now > effect_at
    end

    def recompute_price
      items.each(&:compute_price!)
    end

  end
end
