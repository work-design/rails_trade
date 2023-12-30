module Trade
  class Order < ApplicationRecord
    include Model::Order
    include Crm::Ext::Maintainable if defined? RailsCrm
    if defined? RailsAudit
      include Auditor::Ext::Discard
      include Auditor::Ext::Audited
    end
    if defined? RailsNotice
      include Notice::Order
    end
  end
end
