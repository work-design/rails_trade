class TheTradeMy::BaseController < TheTrade.config.my_class.constantize
  skip_before_action :verify_authenticity_token#, if: -> { request.content_type == 'application/json' }
  helper_method :current_buyer
  
  def current_buyer
    if defined? super
      super
    else
      current_user.buyer
    end
  end

end
