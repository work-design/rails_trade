# see RailsBooking::PlanAttender
module Trade
  module Ext::PlanAttender
    extend ActiveSupport::Concern

    included do
      has_many :card_payments
      has_many :card_returns, as: :consumable

      after_save_commit :sync_card_expense, if: -> { saved_change_to_attended? && attended? }
      after_commit :sync_card_return, if: -> { saved_change_to_attended? && !attended? }
    end

    def sync_card_expense
      return unless self.attender.cards.present?
      card_id = self.attender.card_ids.first

      log = self.card_expenses.build(card_id: card_id)
      log.amount = plan_item.planned.price
      log.save
      log
    end

    def sync_card_return
      self.card_expenses.map do |card_expense|
        log = self.card_returns.build(card_expense_id: card_expense.id)
        log.save
        log
      end
    end

  end
end
