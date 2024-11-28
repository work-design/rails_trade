module Trade
  class Payment < ApplicationRecord
    include Model::Payment
    include Print::Payment
    include Auditor::Ext::Audited if defined? RailsAudit
    include Notice::Payment if defined? RailsNotice
  end
end
