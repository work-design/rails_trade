module Trade
  class Order < ApplicationRecord
    include Model::Order
    include Crm::Ext::Maintainable if defined? RailsCrm
    include Auditor::Ext::Discard if defined? RailsAudit
  end
end
