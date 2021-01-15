module Trade
  class PaypalRefund < Refund
    include Model::Refund::PaypalRefund
  end
end
