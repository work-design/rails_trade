module Trade
  class ScanPayment < WxpayPayment
    include Model::Payment::ScanPayment
  end
end
