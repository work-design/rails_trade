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

      after_save :sync_to_card, if: -> { saved_change_to_amount? }
      after_create_commit :sync_log
    end

    def sync_log
      log = self.card_log || self.build_card_log
      log.title = I18n.t('card_log.income.card_advance.title')
      log.tag_str = I18n.t('card_log.income.card_advance.tag_str')
      log.amount = self.amount
      log.save
    end

    def duration
      years.years + months.months + days.days
    end

    def sync_to_card
      card.expire_at = card.expire_at.since(duration).end_of_day
      card.save!
    end

  end
end
