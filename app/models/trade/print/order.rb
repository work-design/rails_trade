module Trade
  module Print::Order
    extend ActiveSupport::Concern

    included do
      after_save_commit :print, if: -> { paid_at.present? && paid_at_previously_was.blank? }
    end

    def print
      return unless organ&.device
      organ.device.print(
        data: to_tspl
      )
    end

    def to_tspl
      url = Rails.application.routes.url_for(controller: 'trade/my/orders', action: 'show', id: id, host: organ.host)

      ts = BaseTspl.new
      ts.bar(y: 0, height: 20)
      ts.right_qrcode(url, y: 30, cell_width: 5)
      ts.text(serial_str, font: 'TSS32.BF2', x: 10, y:30)
      ts.bar(height: 3, width: 250)
      items.limit(3).each do |item|
        ts.text("#{item.good.name} x #{item.number}", x: 10)
      end
      ts.text(amount, x: 10)
      ts.bar(height: 3, width: 250)
      if address
        ts.text(address.contact_info, x: 10)
        ts.text(address.content, font: 'TSS16.BF2', x: 10)
      end
      if paid_at
        ts.text("#{paid_at.to_fs}", x: 10)
      end
      ts.render
    end
  end
end


