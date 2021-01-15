module Trade
  class Payment < ApplicationRecord
    include RailsTrade::Payment
    include RailsAuditExt::Audited
  end
end
