module Trade
  class Me::HomeController < Me::BaseController

    def qrcode
    end

    def qrcode_file
      send_data(
        QrcodeHelper.code_png(url_for(controller: 'trade/my/wxpay_payments', action: 'new', scope: 'snsapi_base', host: current_organ.host)),
        filename: 'xx.png'
      )
    end

  end
end
