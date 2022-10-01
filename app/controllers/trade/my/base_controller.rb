module Trade
  class My::BaseController < MyController

    private
    def current_payee
      if params[:appid]
        Wechat::App.find_by appid: params[:appid]
      else
        super
      end
    end
  end
end
