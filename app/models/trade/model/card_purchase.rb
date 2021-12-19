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

      enum kind: {
        given: 'given'  # 系统赠送
      }

      belongs_to :card
      belongs_to :trade_item, optional: true
      belongs_to :purchase, optional: true

      has_one :card_log, ->(o){ where(card_id: o.card_id) }, as: :source

      enum state: {
        success: :success,
        failed: :failed
      }

      after_save :sync_to_card, if: -> { (saved_changes.keys & ['years', 'months', 'days']).present? }
    end

    def duration
      years.years + months.months + days.days
    end

    def sync_to_card
      card.expire_at = (card.expire_at || Date.today).since(duration).end_of_day
      card.save!
    end

  end
end
