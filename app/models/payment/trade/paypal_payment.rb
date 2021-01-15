module Trade
  class PaypalPayment < Payment
    include Model::Payment::PaypalPayment
  end
end
