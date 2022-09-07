module Trade
  module Model::Wallet
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :name, :string
      attribute :amount, :decimal, default: 0
      attribute :income_amount, :decimal, default: 0
      attribute :expense_amount, :decimal, default: 0
      attribute :lock_version, :integer

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true

      has_many :wallet_logs
      has_many :payouts
      has_many :wallet_advances
      has_many :wallet_payments, inverse_of: :wallet, dependent: :nullify  # expense
      has_many :wallet_refunds, dependent: :nullify

      validates :amount, numericality: { greater_than_or_equal_to: 0 }
      validates :expense_amount, numericality: { greater_than_or_equal_to: 0 }
      validates :income_amount, numericality: { greater_than_or_equal_to: 0 }

      before_validation :init_from_template, if: -> { wallet_template_id_changed? }
      before_validation :compute_amount, if: -> { (changes.keys & ['income_amount', 'expense_amount']).present? }
      before_validation :init_name, if: -> { (changes.keys & ['maintain_id', 'user_id']).present? }
    end

    def init_from_template
      self.organ_id = wallet_template.organ_id
    end

    def init_name
      self.name ||= maintain.client.name if respond_to?(:maintain) && maintain
    end

    def compute_expense_amount
      self.payouts.sum(:requested_amount) + wallet_payments.sum(:total_amount)
    end

    def compute_income_amount
      self.wallet_advances.sum(:amount)
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
end
