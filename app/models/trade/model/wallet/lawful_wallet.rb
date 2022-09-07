module Trade
  module Model::Wallet::LawfulWallet
    extend ActiveSupport::Concern

    included do
      attribute :withdrawable_amount, :decimal, comment: '可提现的额度'
      attribute :account_bank, :string
      attribute :account_name, :string
      attribute :account_number, :string
    end

  end
end
