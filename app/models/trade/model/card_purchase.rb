module Trade
  module Model::CardPurchase
    extend ActiveSupport::Concern

    included do
      attribute :price, :decimal
      attribute :days, :integer, default: 0
      attribute :months, :integer, default: 0
      attribute :years, :integer, default: 0
      attribute :state, :string
      attribute :note, :string
      attribute :last_expire_at, :datetime

      enum kind: {
        given: 'given'  # 系统赠送
      }

      belongs_to :card
      belongs_to :purchase
      belongs_to :item, optional: true

      has_one :card_log, ->(o){ where(card_id: o.card_id) }, as: :source

      enum state: {
        success: :success,
        failed: :failed
      }

      before_create :sync_from_card
      after_save :sync_to_card, if: -> { (saved_changes.keys & ['years', 'months', 'days']).present? }
      after_destroy :prune_to_card
    end

    def duration
      years.years + months.months + days.days
    end

    def last_expire_on(today = Date.today)
      if last_expire_at && last_expire_at.to_date > today
        last_expire_at.to_date
      else
        today
      end
    end

    def sync_from_card
      self.last_expire_at = card.expire_at
      self.years = purchase.years
      self.months = purchase.months
      self.days = purchase.days
    end

    def sync_to_card
      card.expire_at = self.last_expire_on.since(duration).end_of_day
      card.save!
    end

    def prune_to_card
      card.expire_at = self.last_expire_at
      card.save!
    end

  end
end
