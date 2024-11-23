module Trade
  module Print::Order
    extend ActiveSupport::Concern

    included do
      after_create_commit :print_to_prepare
      after_save_commit :print, if: -> { paid_at.present? && paid_at_previously_was.blank? }
    end

    def print_to_prepare
      return unless organ&.device_produce
      items.each do |item|
        organ.device_produce.print(
          data: to_prepare_esc(item),
          mode: 3,
          cmd_type: 'ESC'
        )
      end
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
        ts.text("#{item.good_name} x #{item.number}", x: 10)
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
      pr.qrcode(qrcode_show_url, y: 20)
      pr.text "#{self.class.human_attribute_name(:created_at)}：#{created_at.to_fs(:wechat)}"
      pr.text "#{self.class.human_attribute_name(:serial_number)}：#{serial_str}" if serial_number
      pr.text '已下单：'
      items.includes(:good).each do |item|
        pr.text("    #{item.good_name} x #{item.number.to_human}") if item.good
      end
      pr.text "#{self.class.human_attribute_name(:item_amount)}：#{item_amount.to_money.to_s}" if item_amount != amount
      pr.text "#{self.class.human_attribute_name(:adjust_amount)}：#{adjust_amount.to_money.to_s}" if adjust_amount.to_d != 0
      pr.text "#{self.class.human_attribute_name(:amount)}：#{amount.to_money.to_s}"
      pr.text "#{self.class.human_attribute_name(:payment_status)}：#{payment_status_i18n}"
      pr.render
      pr.render_raw
    end

    def print_by_ip(printer_ip = '172.30.1.239', printer_port = 9100)
      sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      sock.connect(Socket.pack_sockaddr_in(printer_port, printer_ip))
      begin
        sock.send(to_esc, 0)
        logger.debug "指令已发送到打印机"
      rescue StandardError => e
        logger.debug "发送失败: #{e.message}"
      ensure
        # 关闭连接
        sock.close unless sock.closed?
      end
    end

    def to_prepare_esc(item)
      pr = BaseEsc.new
      pr.big_text("#{item.good_name} x #{item.number.to_human}") if item.good
      pr.text "#{item.class.human_attribute_name(:desk_id)}：#{item.desk.name}" if item.desk
      pr.text "#{item.class.human_attribute_name(:created_at)}：#{item.created_at.to_fs(:wechat)}"
      pr.render
      pr.render_raw
    end

    def to_cpcl
      cpcl = BaseCpcl.new
      cpcl.text serial_str
      cpcl.right_qrcode(qrcode_show_url, y: 20)
      cpcl.render.bytes
    end

  end
end


