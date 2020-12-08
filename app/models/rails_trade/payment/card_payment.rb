module RailsTrade::Payment::CardPayment
  extend ActiveSupport::Concern

  included do
    belongs_to :card
    has_one :card_log, ->(o){ where(card_id: o.card_id) }, as: :source

    before_validation :init_amount, if: -> { checked_amount_changed? }
    after_save :sync_amount, if: -> { saved_change_to_total_amount? }
    after_create_commit :sync_card_log, if: -> { saved_change_to_total_amount? }
  end

  def init_amount
    self.total_amount = checked_amount if total_amount.zero?
  end

  def assign_detail(params)
    self.notified_at = Time.current
    self.total_amount = params[:total_amount]
  end

  def sync_amount
    card.reload
    card.expense_amount += self.total_amount
    computed = card.compute_expense_amount
    if card.expense_amount == computed
      card.save!
    else
      card.errors.add :expense_amount, "#{card.expense_amount} Not Equal Computed #{computed}"
      logger.error "#{self.class.name}/Card: #{card.error_text}"
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
