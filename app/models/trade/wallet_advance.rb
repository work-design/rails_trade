module Trade
  class WalletAdvance < ApplicationRecord
    include Model::WalletAdvance

    attribute :total, :decimal
  end
end
