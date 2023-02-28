module Trade
  class OrderChannel < Turbo::StreamsChannel

    def subscribed
      super

      streams.each_key do |key|
        model = GlobalID.find key
        if model.is_a?(Trade::Order) && model.all_paid?
          model.send_notice
        end
      end
    end

  end
end
