module Trade
  module Print::Payment
    extend ActiveSupport::Concern

    included do
      #after_save_commit :print, if: -> { paid_at.present? && paid_at_previously_was.blank? }
    end

    def print
      if organ&.receipt_printer
        organ.receipt_printer.printer.print do |pr|
          to_esc(pr)
        end
      end
    end

    def qrcode_show_url
      Rails.application.routes.url_for(
        controller: 'trade/my/payments',
        action: 'show',
        id: id,
        host: organ.host
      )
    end

    def to_esc(pr)
      pr.big_text "#{organ.name}"
      pr.break_line
      pr.text '已下单：'
      items.each do |item|
        pr.text(" #{item.good_name} #{item.number.to_human} x #{item.single_price.to_money.to_s}")
      end
      pr.break_line
      pr.text "#{self.class.human_attribute_name(:orders_amount)}：#{orders_amount.to_money.to_s}"
      pr.text "#{self.class.human_attribute_name(:total_amount)}：#{total_amount.to_money.to_s}"
      pr.break_line
      pr.text "感谢您的惠顾！"
      pr.text "订餐电话：#{'0717-6788808'}"
      pr.text "#{self.class.human_attribute_name(:created_at)}：#{created_at.to_fs(:wechat)}"
      pr.text "#{self.class.human_attribute_name(:state)}：#{state_i18n}"
      pr.break_line
      pr.qrcode(qrcode_show_url, y: 20)
      pr.render
      pr
    end

  end
end


