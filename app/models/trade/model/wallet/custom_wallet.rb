module Trade
  module Model::Wallet::CustomWallet
    extend ActiveSupport::Concern

    included do
      belongs_to :wallet_template, counter_cache: true
    end

  end
end
