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
      after_save :sync_to_card!, if: -> { (saved_changes.keys & ['years', 'months', 'days', 'last_expire_at']).present? }
      after_destroy :prune_to_card!
    end

    def duration
      years.years + months.months + days.days
    end

    def sync_from_card
      if card.expire_at && card.expire_at.to_date > Date.today
        self.last_expire_at = card.expire_at
      else
        self.last_expire_at = Date.today.end_of_day
      end
      self.years = purchase.years
      self.months = purchase.months
      self.days = purchase.days
    end

    def sync_to_card!
      expire = self.last_expire_at.since(duration).end_of_day
      card.expire_at = expire if (card.expire_at && card.expire_at < expire) || card.expire_at.blank?
      card.save!
    end

    def prune_to_card!
      card.expire_at = self.last_expire_at
      card.save!
    end

  end
end
