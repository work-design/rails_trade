module Trade
  module Model::Wallet::LawfulWallet
    extend ActiveSupport::Concern

    included do
      attribute :withdrawable_amount, :decimal, comment: '可提现的额度'
      attribute :account_bank, :string
      attribute :account_name, :string
      attribute :account_number, :string

      has_many :advances, -> { where(lawful: true) }, primary_key: :organ_id, foreign_key: :organ_id
    end

  end
end
