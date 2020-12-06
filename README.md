# RailsTrade

处理订单、支付（退款）、促销策略、附加服务策略；

## 特性
* 在购物车环节就可以查看完整的优惠券策略，不必首先生成订单才能知晓全部优惠，能进一步提升转化率，降低系统取消订单数。
* 经典的优惠券策略叠加计算实现，性能佳，实现简单，易于理解；
* 接入了常见的支付方式
  * 微信支付
  * 支付宝
  * PayPal
  * Stripe
  * ApplePay

功能列表
* 会员储值(次)卡，只可用于消费，不能直接提现，有有效期；
* 会员权益，如：有效期不限次，折扣权限；
* 现金(Cash)，只可用于提现，不可用于消费；
* 支付(Payout), 支持微信、支付宝企业付款；
  
## 核心模型
 
* good_type / good_id
 
可进行售卖，出租的实体，将其关联 good 即可处理。

`Good`模型会处理涉及由可交易产生的信息，比如价格、促销方式等。

* User

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
* original_amount: 商品原价
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

## License
License 采用 [LGPL-3.0](https://opensource.org/licenses/LGPL-3.0).
