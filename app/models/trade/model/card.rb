module Trade
  module Model::Card
    extend ActiveSupport::Concern

    included do
      attribute :card_uuid, :string
      attribute :effect_at, :datetime
      attribute :expire_at, :datetime
      attribute :amount, :decimal, default: 0
      attribute :income_amount, :decimal, default: 0
      attribute :expense_amount, :decimal, default: 0
      attribute :lock_version, :integer

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :cart

      belongs_to :card_template, counter_cache: true
      belongs_to :trade_item, optional: true
      belongs_to :client, optional: true
      belongs_to :agency, optional: true

      has_many :card_purchases, dependent: :nullify
      has_many :card_logs, dependent: :destroy_async
      has_many :card_promotes, ->(o){ default_where('income_min-lte': o.income_amount, 'income_max-gt': o.income_amount) }, foreign_key: :card_template_id, primary_key: :card_template_id
      has_many :promotes, through: :card_promotes
      has_many :plan_attenders, ->(o){ where(attender_type: o.client_type) }, foreign_key: :attender_id, primary_key: :client_id

      validates :expense_amount, numericality: { greater_than_or_equal_to: 0 }
      validates :income_amount, numericality: { greater_than_or_equal_to: 0 }
      validates :amount, numericality: { greater_than_or_equal_to: 0 }

      before_validation :sync_from_card_template
    end

    def sync_from_card_template
      self.card_uuid ||= UidHelper.nsec_uuid('CARD')
      if card_template
        self.organ_id ||= card_template.organ_id
        self.effect_at ||= Time.current
      end
    end

  end
end
