module RailsTrade::CardReturn
  extend ActiveSupport::Concern

  included do
    attribute :amount, :decimal

    belongs_to :card
    belongs_to :card_expense
    belongs_to :consumable, polymorphic: true
    has_one :card_log, ->(o){ where(card_id: o.card_id) }, as: :source

    before_validation :sync_card
    after_save :sync_amount, if: -> { saved_change_to_amount? }
    after_create_commit :sync_card_log
  end

  def sync_card
    self.card = card_expense.card
    self.amount = card_expense.amount
  end

  def sync_amount
    card.reload
    card.income_amount += self.amount
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
    cl.amount = self.amount
    cl.save
  end

end
