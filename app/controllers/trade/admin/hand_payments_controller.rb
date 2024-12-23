module Trade
  class Admin::HandPaymentsController < Admin::PaymentsController

    def batch
      @payment = HandPayment.init_with_order_ids params[:ids].split(',')
    end

  end
end
