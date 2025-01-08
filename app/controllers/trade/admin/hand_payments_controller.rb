module Trade
  class Admin::HandPaymentsController < Admin::PaymentsController

    def batch
      @payment = HandPayment.init_with_order_ids params[:ids].split(',')
    end

    def desk
      order_ids = Item.where(status: 'ordered', desk_id: params[:desk_id]).select(:order_id).distinct.pluck(:order_id)

      @payment = HandPayment.init_with_order_ids order_ids
    end

  end
end
