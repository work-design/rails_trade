module RailsVip::Cash
  extend ActiveSupport::Concern

  included do
    attribute :amount, :decimal, precision: 10, scale: 2, default: 0
    attribute :income_amount, :decimal, precision: 10, scale: 2, default: 0
    attribute :expense_amount, :decimal, precision: 10, scale: 2, default: 0
    attribute :account_bank, :string
    attribute :account_name, :string
    attribute :account_number, :string
    attribute :lock_version, :integer

    belongs_to :user
    has_many :cash_logs
    has_many :payouts
    has_many :cash_givens, as: :money
  
    validates :user, presence: true, uniqueness: true
    validates :amount, numericality: { greater_than_or_equal_to: 0 }
  end
  
  def compute_expense_amount
    self.payouts.sum(:requested_amount)
  end

  def compute_income_amount
    self.cash_givens.sum(:amount)
  end

end
