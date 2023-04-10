module Trade
  class Mem::LawfulWalletsController < My::LawfulWalletsController
    include Controller::Mem

    private
    def set_new_order
      @order = current_client.orders.build
      @order.items.build
    end

  end
end
