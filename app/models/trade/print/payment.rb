module Trade
  module Print::Payment
    extend ActiveSupport::Concern

    included do
      attribute :print_info, :json, default: {}
      #after_save_commit :print, if: -> { paid_at.present? && paid_at_previously_was.blank? }
    end

    def print
      if organ.receipt_printer
        organ.receipt_printer.print(to_gid) do |pr|
          to_esc(pr)
        end
      end
    end

    def qrcode_show_url
      Rails.app.routes.url_for(
        controller: 'trade/my/payments',
        action: 'show',
        id: id,
        host: organ.host
      )
    end

    def to_esc(pr)
      pr.text_big_center "#{organ.name}"
      pr.break_line
      pr.text '已下单：'
      pr.dash
      cols = items.map do |item|
        [item.good_name, item.single_price.to_money.to_s, item.number.to_human, item.amount.to_money.to_s]
      end
      pr.table_3(cols: cols)
      pr.dash
      pr.break_line
      pr.text "#{self.class.human_attribute_name(:orders_amount)}：#{orders_amount.to_money.to_s}"
      pr.text "#{self.class.human_attribute_name(:total_amount)}：#{total_amount.to_money.to_s}"
      pr.break_line
      organ.print_note.to_s.split("\n").each do |note|
        pr.text note
      end
      pr.text "#{self.class.human_attribute_name(:created_at)}：#{created_at.to_fs(:wechat)}"
      pr.text "#{self.class.human_attribute_name(:state)}：#{state_i18n}"
      pr.break_line
      pr.qrcode(qrcode_show_url, y: 20)
    end

  end
end


