module Trade
  module Print::Order
    extend ActiveSupport::Concern

    included do
      after_create_commit :print_to_prepare
      after_save_commit :print, if: -> { paid_at.present? && paid_at_previously_was.blank? }
    end

    def print_to_prepare
      return unless organ&.device
      organ.device.print(
        data: to_prepare_esc,
        mode: 3,
        cmd_type: 'ESC'
      )
    end

    def print
      return unless organ&.device
      organ.device.print(
        data: to_esc,
        mode: 3,
        cmd_type: 'ESC'
      )
    end

    def qrcode_show_url
      Rails.application.routes.url_for(
        controller: 'trade/my/orders',
        action: 'show',
        id: id,
        host: organ.host
      )
    end

    def to_tspl
      ts = BaseTspl.new
      ts.bar(y: 0, height: 20)
      ts.right_qrcode(qrcode_show_url, y: 30, cell_width: 5)
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

    def to_esc
      pr = BaseEsc.new
      share_print_esc(pr)
      pr.qrcode(qrcode_show_url, y: 20)
      pr.render
    end

    def to_prepare_esc
      pr = BaseEsc.new
      share_print_esc(pr)
      pr.render
    end

    def share_print_esc(pr)
      pr.text "#{self.class.human_attribute_name(:created_at)}：#{created_at.to_fs(:wechat)}"
      pr.text "#{self.class.human_attribute_name(:serial_number)}：#{serial_str}" if serial_number
      pr.text '已下单：'
      items.each do |item|
        pr.text("#{item.good.name} x #{item.number.to_human}")
      end
      pr.text "#{self.class.human_attribute_name(:state)}：#{state_i18n}"
    end

    def to_cpcl
      cpcl = BaseCpcl.new
      cpcl.text serial_str
      cpcl.right_qrcode(qrcode_show_url, y: 20)
      cpcl.render.bytes
    end

  end
end


