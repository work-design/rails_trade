module Trade
  class ApplePayment < Payment
    include Model::Payment::ApplePayment
  end
end
