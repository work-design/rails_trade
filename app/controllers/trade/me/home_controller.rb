module Trade
  class Me::HomeController < Me::BaseController
    before_action :set_url, only: [:qrcode, :qrcode_file]

    def qrcode
    end

    def qrcode_file
      send_data(
        QrcodeHelper.code_png(@url),
        filename: 'xx.png'
      )
    end

    priviate
    def set_url
      @url = url_for(controller: 'trade/my/wxpay_payments', action: 'new', scope: 'snsapi_base', host: current_organ.host)
    end

  end
end
