module Trade
  module Controller::My
    extend ActiveSupport::Concern

    private
    def set_cart
      @cart = current_carts.find_or_initialize_by(good_type: nil)
    end

    def set_lawful_wallet
      @lawful_wallet = current_user.lawful_wallets.find_by(default_params) || current_user.lawful_wallets.create(default_params)
    end

  end
end
