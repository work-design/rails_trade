json.array!(@orders) do |order|
  json.extract! order, :id, :uuid, :amount, :subtotal
  json.order_items order.order_items do |oi|
    json.extract! oi, :id
    json.sku oi.good.sku
    json.name oi.good.name
    json.quantity oi.quantity
  end
end
