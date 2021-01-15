module Trade
  class BankPayment < Payment
    include Model::Payment::BankPayment
  end
end
