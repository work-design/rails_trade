json.order do
  json.extract! @order, :id, :uuid, :amount, :payment_status, :buyer_id, :buyer_type
  json.buyer do
    json.extract! @order.buyer, :id, :name
  end
  json.order_items @order.order_items do |order_item|
    json.extract! order_item, :id, :number, :amount
    json.advance order_item.good, :id, :name, :price, :final_price, :apple_product_id, :amount
  end
end

if @wxpay_order
  json.wxpay_order @wxpay_order
end
