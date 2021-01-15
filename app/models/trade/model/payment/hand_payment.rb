module Trade
  module Model::Payment::HandPayment

    def assign_detail(params)
      self.notified_at = Time.current
      self.total_amount = params[:total_amount]
    end

  end
end
