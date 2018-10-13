class Trade::My::BaseController < RailsTrade.config.my_class.constantize
  skip_before_action :verify_authenticity_token#, if: -> { request.content_type == 'application/json' }
  helper_method :current_buyer

  def current_buyer
    if defined? super
      super
    elsif current_user.buyer_type == 'User'
      current_user
    else
      current_user
    end
  end

end
