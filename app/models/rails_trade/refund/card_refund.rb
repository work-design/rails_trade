module RailsTrade::Refund::CardRefund
  extend ActiveSupport::Concern

  included do
    belongs_to :card
    has_one :card_log, ->(o){ where(card_id: o.card_id) }, as: :source

    before_validation :sync_card, if: -> { payment_id_changed? }
    after_save :sync_amount, if: -> {  saved_change_to_total_amount? }
    after_create_commit :sync_card_log
  end

  def sync_card
    self.card = payment.card
    self.total_amount = payment.total_amount
  end

  def sync_amount
    card.reload
    card.income_amount += self.total_amount
    if card.income_amount == card.compute_income_amount
      card.save!
    else
      card.errors.add :income_amount, 'not equal'
      logger.error "#{self.class.name}/Card: #{card.errors.full_messages.join(', ')}"
      raise ActiveRecord::RecordInvalid.new(card)
    end
  end

  def sync_card_log
    cl = self.card_log || self.build_card_log
    cl.title = card.card_uuid
    cl.tag_str = '虚拟币退款'
    cl.amount = self.total_amount
    cl.save
  end

end
