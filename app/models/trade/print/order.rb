module Trade
  module Print::Order
    extend ActiveSupport::Concern

    included do
      attribute :print_info, :json, default: {}

      #after_create_commit :print, if: -> { organ&.produce_printer }
      #after_save_commit :print, if: -> { paid_at.present? && paid_at_previously_was.blank? }
    end

    def print_to_prepare
      organ.printer.print(to_gid, aim: 'produce')
      organ.printer.print(to_gid, aim: 'receipt')

      task = printer.inner_tasks.build(gid: gid, aim: aim)
    end

    def qrcode_show_url
      Rails.app.routes.url_for(
        controller: 'trade/my/orders',
        action: 'show',
        id: id,
        host: organ.host
      )
    end

    def to_esc(pr, aim: 'xx')
      case aim
      when 'prepare'
        pr.text_big_center organ.name
        pr.dash
        pr.break_line
        pr.text "#{self.class.human_attribute_name(:serial_number)}：#{serial_str}" if serial_number
        pr.text '已下单：'
        pr.dash
        cols = items.map do |item|
          [item.good_name, item.single_price.to_money.to_s, item.number.to_human, item.amount.to_money.to_s]
        end
        pr.table_3(cols: cols)
        pr.break_line
        pr.dash
        pr.text "#{self.class.human_attribute_name(:item_amount)}：#{item_amount.to_money.to_s}" if item_amount != amount
        pr.text "#{self.class.human_attribute_name(:adjust_amount)}：#{adjust_amount.to_money.to_s}" if adjust_amount.to_d != 0
        pr.text "#{self.class.human_attribute_name(:amount)}：#{amount.to_money.to_s}"
        pr.text "#{self.class.human_attribute_name(:payment_status)}：#{payment_status_i18n}"
        pr.break_line
        pr.qrcode(qrcode_show_url, y: 20)
        organ.print_note.to_s.split("\n").each do |note|
          pr.text note
        end
        pr.text "#{created_at.to_fs(:wechat)}"
      when 'prepare'
        items.each do |item|
          pr.text_big("#{item.good_name} x #{item.number.to_human}") if item.good
          pr.break_line
          pr.text "#{item.class.human_attribute_name(:desk_id)}：#{item.desk.name}" if item.desk
          pr.text "#{item.class.human_attribute_name(:created_at)}：#{item.created_at.to_fs(:wechat)}"
        end
      when 'address'
        pr.bar(y: 0, height: 20)
        pr.qrcode_right(qrcode_show_url, y: 30, cell_width: 5)
        pr.text(serial_str, font: 'TSS32.BF2', x: 10, y:30)
        pr.bar(height: 3, width: 250)
        items.limit(3).each do |item|
          pr.text("#{item.good_name} x #{item.number}", x: 10)
        end
        pr.text(amount, x: 10)
        pr.bar(height: 3, width: 250)
        if address
          pr.text(address.contact_info, x: 10)
          pr.text(address.content, font: 'TSS16.BF2', x: 10)
        end
        if paid_at
          pr.text("#{paid_at.to_fs}", x: 10)
        end
      end
    end

  end
end


