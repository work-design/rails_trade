module Trade
  class Payment < ApplicationRecord
    include Model::Payment
    include Auditor::Ext::Audited
  end
end
