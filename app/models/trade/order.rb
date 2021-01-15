module Trade
  class Order < ApplicationRecord
    include Model::Order
    include Model::Amount
    include Ordering::Payment
    include Ordering::Refund
  end
end
