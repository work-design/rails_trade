module Trade
  module Print::Order

    def print
      r = organ.device.print(
        data: to_tspl,
        msg_no: uuid
      )
    end

    def to_tspl
      url = Rails.application.routes.url_for(controller: 'trade/my/orders', action: 'show', id: id, host: organ.host)
      ts = BaseTspl.new
      ts.bar(height: 20)
      ts.qrcode(url, x: 20, y: 30, cell_width: 5)
      ts.text(uuid, x: 320, scale: 2)
      ts.middle_text('订单详情', x: 320)
      ts.render
    end
  end
end


