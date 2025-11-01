module Trade
  class Admin::HandPaymentsController < Admin::PaymentsController

    def batch
      @payment = HandPayment.init_with_order_ids params[:ids].split(',')
    end

    def desk
      order_ids = Order.where(payment_status: ['unpaid', 'part_paid'], desk_id: params[:desk_id]).pluck(:id)

      @payment = HandPayment.init_with_order_ids order_ids
    end

  end
end
