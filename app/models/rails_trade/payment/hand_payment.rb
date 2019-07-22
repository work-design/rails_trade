module RailsTrade::Payment::HandPayment
  
  def assign_detail(params)
    self.notified_at = Time.now
    self.total_amount = params[:total_amount]
  end

end
