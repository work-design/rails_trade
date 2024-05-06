module Trade
  class Wallet < ApplicationRecord
    include Model::Wallet
    include Crm::Ext::Maintainable if defined? RailsCrm
    if defined? RailsAudit
      include Auditor::Ext::Discard
    end
  end
end
