module Trade
  module Controller::Application
    extend ActiveSupport::Concern

    included do
      helper_method :current_cart, :current_cart_count, :current_wallet
    end

    def current_cart
      return @current_cart if @current_cart

      if current_user
        options = {}
        options.merge! default_form_params
        options.merge! client_params
        @current_cart = current_user.carts.find_by(options) || current_user.carts.create(options)
      end
      logger.debug "\e[33m  Current Trade cart: #{@current_cart&.id}  \e[0m"
      @current_cart
    end

    def current_wallet
      return @current_wallet if @current_wallet

      wallet_template = WalletTemplate.default_where(default_params).default.take
      if wallet_template
        @current_wallet = current_user.wallets.find_or_initialize_by(wallet_template_id: wallet_template.id)
      end

      @current_wallet
    end

    def current_cart_count(good_type: 'Factory::Production')
      if current_cart
        current_cart.trade_items.select(&->(i){ i.persisted? && i.good_type == good_type }).size
      else
        0
      end
    end

  end
end
