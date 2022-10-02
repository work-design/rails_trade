module Trade
  class My::BaseController < MyController

    private
    def current_payee
      if params[:appid]
        return @current_payee if defined?(@current_payee)
        @current_payee = Wechat::Payee.default_where(default_params).find_by(appid: params[:appid])
      else
        super
      end
    end
  end
end
