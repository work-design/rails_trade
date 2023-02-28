module Trade
  class OrderChannel < Turbo::StreamsChannel

    def subscribed
      super

      streams.each do |stream|
        model = GlobalID.find stream
        if model.is_a?(Trade::Order) && model.all_paid?
          model.send_notice
        end
      end
    end

  end
end
