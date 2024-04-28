module Trade
  module Print::Order

    def print
      r = organ.device.print(
        data: to_tspl
      )
    end

    def to_tspl
      url = Rails.application.routes.url_for(controller: 'trade/my/orders', action: 'show', id: id, host: organ.host)

      ts = BaseTspl.new
      ts.bar(y: 0, height: 20)
      ts.right_qrcode(url, y: 30, cell_width: 5)
      ts.text(uuid, x: 10, y:30)
      items.limit(3).each do |item|
        ts.text("#{item.good.name} x #{item.number}", x: 10)
      end
      ts.text(amount.to_money.format(html_wrap: false), x: 10)
      ts.bar(height: 3, width: 200)
      ts.text(serial_number, font: 'TSS32.BF2', x: 10)
      if address
        ts.text(address.contact_info, x: 10)
        ts.text(address.content, font: 'TSS16.BF2', x: 10)
      end
      ts.text("打包于 #{Date.today}", x: 10)
      ts.render
    end
  end
end


