module Trade
  class Wallet < ApplicationRecord
    include Model::Wallet
    include Crm::Ext::Maintainable if defined? RailsCrm
  end
end
