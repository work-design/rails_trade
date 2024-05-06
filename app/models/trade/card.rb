module Trade
  class Card < ApplicationRecord
    include Model::Card
    include Crm::Ext::Maintainable if defined? RailsCrm
    if defined? RailsAudit
      include Auditor::Ext::Discard
    end
  end
end
