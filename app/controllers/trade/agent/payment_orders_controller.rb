module Trade
  class Agent::PaymentOrdersController < Admin::PaymentOrdersController
    include Controller::Agent

    def index
      @payment_orders = @payment.payment_orders
      if @payment.user_id
        @contact = @payment.user.client_contacts.find_or_create_by(organ_id: current_organ.id)
        @contact.maintains.find_or_create_by(member_id: current_member.id)
      end
    end

  end
end

