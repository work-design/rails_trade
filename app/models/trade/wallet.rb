module Trade
  class Wallet < ApplicationRecord
    include Model::Wallet
    include Model::Compute
  end
end
