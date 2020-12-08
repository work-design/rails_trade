module RailsTrade::Compute
  extend ActiveSupport::Concern

  included do
    attribute :amount, :decimal, default: 0
    attribute :income_amount, :decimal, default: 0
    attribute :expense_amount, :decimal, default: 0

    validates :expense_amount, numericality: { greater_than_or_equal_to: 0 }
    validates :income_amount, numericality: { greater_than_or_equal_to: 0 }

    before_validation :compute_amount, if: -> { (changes.keys & ['income_amount', 'expense_amount']).present? }
  end

  def compute_amount
    self.amount = self.income_amount - self.expense_amount
  end

  def reset_amount
    self.income_amount = compute_income_amount
    self.expense_amount = compute_expense_amount
    self.valid?
    self.changes
  end

  def reset_amount!(*args)
    self.reset_amount
    self.save(*args)
  end

end
