module Trade
  module Model::Wallet
    extend ActiveSupport::Concern

    included do
      attribute :amount, :decimal, precision: 10, scale: 2, default: 0
      attribute :withdrawable_amount, :decimal, comment: '可提现的额度'
      attribute :income_amount, :decimal, precision: 10, scale: 2, default: 0
      attribute :expense_amount, :decimal, precision: 10, scale: 2, default: 0
      attribute :account_bank, :string
      attribute :account_name, :string
      attribute :account_number, :string
      attribute :lock_version, :integer
      attribute :default, :boolean

      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :wallet_template, counter_cache: true

      has_many :wallet_logs
      has_many :payouts
      has_many :wallet_advances
      has_many :wallet_payments, dependent: :nullify  # expense
      has_many :wallet_refunds, dependent: :nullify

      scope :default, -> { where(default: true) }

      validates :amount, numericality: { greater_than_or_equal_to: 0 }


      before_validation :init_from_template
      after_save :set_default, if: -> { default? && saved_change_to_default? }
    end

    def init_from_template
      self.default = wallet_template.default
    end

    def compute_expense_amount
      self.payouts.sum(:requested_amount) + wallet_payments.sum(:total_amount)
    end

    def compute_income_amount
      self.wallet_advances.sum(:amount)
    end

    def set_default
      self.class.where.not(id: self.id).where(user_id: user_id, member_id: member_id, default: true).update_all(default: false)
    end

  end
end
