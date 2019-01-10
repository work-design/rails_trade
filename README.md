# RailsTrade

处理订单、支付（退款）、促销策略、附加服务策略；

## 核心模型
 
* good_type / good_id
 
可进行售卖，出租的实体，将其关联 good 即可处理。

`Good`模型会处理涉及由可交易产生的信息，比如价格、促销方式等。

* User/Buyer

## 生成订单的两种方式 

* 基于购物车生成订单；
```
Good -> [CartItem] -> Order(OrderItem) <=> Payment
 └ Promote(Serve)
```
* 直接生成订单；
  
## 集成商品编辑信息
```erb

```
  
OrderItem <=> Shipment
         
* Buyer
 
* Provider

## 购物车中价格字段说明

cart/cart_item 中价格字段说明

* single_price: 商品单价
* original_price: 商品原价
* retail_price: 零售价（）
* final_price: 最终价格

## 注意
* Order: amount, received_amount
* Payment: total_amount, checked_amount
* PaymentOrder: check_amount

### 依赖
* [default_form](https://github.com/qinmingyuan/default_form)
* [default_where](https://github.com/qinmingyuan/default_where)
* [rails_audit](https://github.com/work-design/rails_audit)
* [rails_data](https://github.com/work-design/rails_data)
  * admin/payments
* [rails_role](https://github.com/work-design/rails_role)
  * admin/payments_controller
