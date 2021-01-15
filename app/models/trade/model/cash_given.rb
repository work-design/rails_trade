module RailsTrade::CashGiven
  extend ActiveSupport::Concern

  included do
    attribute :title, :string
    attribute :amount, :decimal, default: 0
    attribute :note, :string

    belongs_to :cash
    belongs_to :organ, optional: true

    has_one :cash_log, ->(o){ where(user_id: o.money_id) }, as: :source

    after_save :sync_to_money, if: -> { saved_change_to_amount? }
    after_create_commit :sync_log
  end

  def sync_log
    cl = self.cash_log || self.build_cash_log
    cl.title = self.title || I18n.t('cash_log.income.cash_given.title')
    cl.tag_str = I18n.t('cash_log.income.cash_given.tag_str')
    cl.amount = self.amount
    cl.save
  end

  def sync_to_money
    cash = user.cash.reload
    cash.income_amount += self.amount
    if cash.income_amount == cash.compute_income_amount
      cash.save!
    else
      cash.errors.add :income_amount, 'not equal'
      logger.error "#{self.class.name}/Cash: #{cash.errors.full_messages.join(', ')}"
      raise ActiveRecord::RecordInvalid.new(cash)
    end
  end

end
