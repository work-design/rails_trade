module Trade
  module Print::Payment
    extend ActiveSupport::Concern

    included do
      #after_save_commit :print, if: -> { paid_at.present? && paid_at_previously_was.blank? }
    end

    def print
      if organ&.receipt_printer
        organ.receipt_printer.printer.print(to_esc)
      end
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

  end
end


