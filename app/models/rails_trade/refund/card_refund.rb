module RailsTrade::Refund::CardRefund
  extend ActiveSupport::Concern

  included do
    belongs_to :card
    has_one :card_log, ->(o){ where(card_id: o.card_id) }, as: :source

    before_validation :sync_card, if: -> { payment.card_id != card_id }
    after_save :sync_amount, if: -> { completed? && (state_before_last_save == 'init' || saved_change_to_total_amount?) }
    after_create_commit :sync_card_log
  end

  def do_refund(params = {})
    self.state = 'completed'
  end

  def sync_card
    self.card = payment.card
    self.total_amount = payment.total_amount
  end

  def sync_amount
    card.reload
    card.expense_amount -= self.total_amount
    computed = card.compute_expense_amount
    if card.expense_amount == computed
      card.save!
    else
      card.errors.add :amount, "  #{card.expense_amount} Not Equal Computed #{computed}"
      logger.error "#{self.class.name}/Card: #{card.error_text}"
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
