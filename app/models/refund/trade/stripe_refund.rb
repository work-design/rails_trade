module Trade
  class StripeRefund < Refund
    include Model::Refund::StripeRefund
  end
end
