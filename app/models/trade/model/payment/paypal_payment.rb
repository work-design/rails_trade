module Trade
  module Model::Payment::PaypalPayment

    def assign_detail(trans)
      self.payment_uuid = trans.related_resources[0].sale.id
      self.total_amount = trans.amount.total
    end

  end
end
