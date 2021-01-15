module Trade
  module Model::Payment::ApplePayment

    def assign_detail(params)
      self.total_amount = params[:total_amount]
    end

  end
end
