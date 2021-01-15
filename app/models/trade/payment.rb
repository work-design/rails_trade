module Trade
  class Payment < ApplicationRecord
    include Model::Payment
    include RailsAuditExt::Audited
  end
end
