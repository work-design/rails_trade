class My::TheTradeController < TheTrade.config.my_class.constantize
  skip_before_action :verify_authenticity_token#, if: -> { request.content_type == 'application/json' }

  def current_buyer
    if defined? super
      super
    else
      current_user.buyer
    end
  end

end
