class Trade::My::BaseController < RailsTrade.config.my_controller.constantize
  skip_before_action :verify_authenticity_token#, if: -> { request.content_type == 'application/json' }
  helper_method :current_cart

  def current_cart
  
  end

end
