json.array!(@orders) do |order|
  json.extract! order, :id, :uuid, :amount, :subtotal
  json.order_items order.order_items do |oi|
    json.extract! oi, :id
    json.sku oi.good&.sku
    json.name oi.good&.name
    json.quantity oi.quantity
  end
  json.refunds order.refunds do |refund|
    refund.extract! refund, :id, :total_amount
  end
end
