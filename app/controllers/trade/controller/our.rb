module Trade
  module Controller::Our
    extend ActiveSupport::Concern

    private
    def set_cart
      @cart = current_carts.find_or_initialize_by(good_type: nil)
    end

    def set_lawful_wallet
      @lawful_wallet = current_client.organ.lawful_wallets.find_by(default_params) || current_client.organ.lawful_wallets.create(default_params)
    end

  end
end
