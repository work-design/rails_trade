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
      attribute :currency, :string

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :user, class_name: 'Auth::User', optional: true

      belongs_to :card_template
      belongs_to :trade_item, optional: true
      belongs_to :member, optional: true
      belongs_to :client, optional: true
      belongs_to :agency, optional: true

      has_many :card_advances, dependent: :nullify  # income
      has_many :card_refunds, dependent: :nullify  # income
      has_many :card_payments, dependent: :nullify  # expense
      has_many :card_logs, dependent: :destroy
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
        self.currency = card_template.currency
        self.effect_at ||= Time.current
        self.expire_at ||= compute_expire_at
      end
    end

    def compute_expire_at
      self.expire_at = self.effect_at.since(card_template.duration).end_of_day
    end

    def compute_income_amount
      card_advances.sum(:amount)
    end

    def compute_expense_amount
      card_payments.sum(:total_amount)
    end

  end
end
