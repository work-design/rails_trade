class My::TheTradeController < TheTrade.config.my_class.constantize
  skip_before_action :verify_authenticity_token#, if: -> { request.content_type == 'application/json' }

  def current_buyer
    current_user.buyer
  end

end
