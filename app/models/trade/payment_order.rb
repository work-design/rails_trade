module Trade
  class PaymentOrder < ApplicationRecord
    include Model::PaymentOrder
    include Auditor::Ext::Audited
  end
end
