module Trade
  module Model::Wallet
    extend ActiveSupport::Concern
    include Inner::User

    included do
      attribute :type, :string
      attribute :name, :string
      attribute :amount, :decimal, default: 0
      attribute :frozen_amount, :decimal, default: 0, comment: '支出：冻结金额'
      attribute :payout_amount, :decimal, default: 0, comment: '支出：提现'
      attribute :payment_amount, :decimal, default: 0, comment: '支出：钱包支付'
      attribute :refunded_amount, :decimal, default: 0, comment: '收入：退款'
      attribute :advances_amount, :decimal, default: 0, comment: '收入：主动充值'
      attribute :sells_amount, :decimal, default: 0, comment: '收入：交易入账'
      attribute :income_amount, :decimal, default: 0
      attribute :expense_amount, :decimal, default: 0
      attribute :lock_version, :integer

      belongs_to :wallet_template, counter_cache: true, optional: true

      has_many :wallet_logs
      has_many :wallet_sells
      has_many :payouts
      has_many :wallet_advances, inverse_of: :wallet
      has_many :wallet_payments, inverse_of: :wallet  # expense
      has_many :wallet_refunds
      has_many :wallet_frozens

      accepts_nested_attributes_for :wallet_frozens

      validates :amount, numericality: { greater_than_or_equal_to: 0 }
      validates :expense_amount, numericality: { greater_than_or_equal_to: 0 }
      validates :income_amount, numericality: { greater_than_or_equal_to: 0 }

      before_validation :compute_expense_amount, if: -> { (changes.keys & ['frozen_amount', 'payout_amount', 'payment_amount']).present? }
      before_validation :compute_income_amount, if: -> { (changes.keys & ['advances_amount', 'sells_amount', 'refunded_amount']).present? }
      before_validation :compute_amount, if: -> { (changes.keys & ['income_amount', 'expense_amount']).present? }
      before_validation :init_name, if: -> { (changes.keys & ['maintain_id', 'user_id']).present? }
      before_validation :sync_organ_id, if: -> { wallet_template_id && wallet_template_id_changed? }
    end

    def init_name
      self.name ||= maintain.client.name if respond_to?(:maintain) && maintain
    end

    def template_name
    end

    def sync_organ_id
      return unless wallet_template
      self.organ_id = wallet_template.organ_id
    end

    def reset_expense_amount
      self.frozen_amount = wallet_frozens.sum(:amount)
      self.payout_amount = payouts.sum(:requested_amount)
      self.payment_amount = wallet_payments.state_all_checked.sum(:total_amount)
      compute_expense_amount
    end

    def compute_expense_amount
      self.expense_amount = self.frozen_amount.to_d + self.payout_amount.to_d + self.payment_amount.to_d
    end

    def reset_income_amount
      self.advances_amount = wallet_advances.sum(:amount)
      self.sells_amount = wallet_sells.sum(:amount)
      self.refunded_amount = wallet_refunds.sum(:total_amount)
      compute_income_amount
    end

    def compute_income_amount
      self.income_amount = self.advances_amount.to_d + self.sells_amount.to_d + self.refunded_amount.to_d
    end

    def compute_amount
      self.amount = self.income_amount - self.expense_amount
    end

    def reset_amount
      self.compute_income_amount
      self.compute_expense_amount
      self.valid?
      self.changes
    end

    def reset_amount!(*args)
      self.reset_income_amount
      self.reset_expense_amount
      self.save(*args)
    end

  end
end
