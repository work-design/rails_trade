module RailsVip::CardPayment
  extend ActiveSupport::Concern

  included do
    belongs_to :card
    has_one :card_log, ->(o){ where(card_id: o.card_id) }, as: :source

    after_save :sync_amount, if: -> { saved_change_to_total_amount? }
    after_create_commit :sync_card_log
  end

  def sync_amount
    card.reload
    card.expense_amount += self.total_amount
    if card.expense_amount == card.compute_expense_amount
      card.save!
    else
      card.errors.add :expense_amount, 'not equal'
      logger.error "#{self.class.name}/Card: #{card.errors.full_messages.join(', ')}"
      raise ActiveRecord::RecordInvalid.new(card)
    end
  end

  def sync_card_log
    cl = self.card_log || self.build_card_log
    cl.title = card.card_uuid
    cl.tag_str = '支出'
    cl.amount = -self.total_amount
    cl.save
  end

end
