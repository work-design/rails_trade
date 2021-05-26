module Trade
  module Model::CardAdvance
    extend ActiveSupport::Concern

    included do
      attribute :price, :decimal
      attribute :amount, :decimal
      attribute :state, :string
      attribute :note, :string

      enum kind: {
        given: 'given'  # 系统赠送
      }

      belongs_to :card
      belongs_to :trade_item, optional: true
      belongs_to :advance, optional: true
      belongs_to :card_prepayment, optional: true

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

    def sync_to_card
      card.reload
      card.income_amount += self.amount
      if card.income_amount == card.compute_income_amount
        card.save!
      else
        card.errors.add :income_amount, 'not equal'
        logger.error "#{self.class.name}/Card: #{card.error_text}"
        raise ActiveRecord::RecordInvalid.new(card)
      end
    end

  end
end
