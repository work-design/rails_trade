module Trade
  module Model::CardPurchase
    extend ActiveSupport::Concern

    included do
      attribute :price, :decimal
      attribute :note, :string
      attribute :valid_years, :integer, default: 0
      attribute :valid_months, :integer, default: 0
      attribute :valid_days, :integer, default: 0

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

  end
end
