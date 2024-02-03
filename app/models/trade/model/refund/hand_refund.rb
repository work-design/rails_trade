module Trade
  module Model::Refund::HandRefund

    def do_refund(params = {})
      self.state = 'completed'
      self.refunded_at = Time.current
      self
    end

  end
end
