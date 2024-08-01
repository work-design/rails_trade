module Trade
  module Controller::My
    extend ActiveSupport::Concern
    include Controller::Application

    private
    def set_cart
      @cart = Cart.get_cart(params, good_type: nil, user_id: current_user.id, **default_form_params)
      logger.debug "my cart #{@cart.id}"
    end

    def set_lawful_wallet
      @lawful_wallet = current_user.lawful_wallets.find_by(default_params) || current_user.lawful_wallets.create(default_params)
    end

    def set_card_templates
      open_template_ids = current_user.cards.default_where(default_params).effective.pluck(:card_template_id).uniq
      min_grade = Trade::CardTemplate.default_where(default_params).minimum(:grade)
      @open_card_templates = Trade::CardTemplate.where(id: open_template_ids)
      @card_templates = Trade::CardTemplate.default_where(default_params).where.not(id: open_template_ids).where(grade: min_grade).limit(3)
    end

    def set_wallet_template
      @wallets = current_user.custom_wallets.default_where(default_params)
      @wallet_templates = Trade::WalletTemplate.default_where(default_params).where.not(id: @wallets.pluck(:wallet_template_id)).limit(3)
    end

  end
end
