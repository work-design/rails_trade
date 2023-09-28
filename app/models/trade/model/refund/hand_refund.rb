module Trade
  module Model::Refund::HandRefund

    def do_refund(params = {})
      self.state = 'completed'
    end

  end
end
