module Trade
  class My::BaseController < MyController

    private
    def current_wechat_app
      if params[:appid]
        Wechat::App.find_by appid: params[:appid]
      else
        super
      end
    end
  end
end
