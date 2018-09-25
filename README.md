# RailsTrade

处理订单、支付（退款）、促销策略、附加服务策略；

## 核心模型
 
* good_type / good_id
 
可进行售卖，出租的实体，将其关联 good 即可处理。

`Good`模型会处理涉及由可交易产生的信息，比如价格、促销方式等。

* User/Buyer

## 流程  

```
Good -> [CartItem] -> Order(OrderItem) <=> Payment
 └ Promote(Serve)
```
  
## 集成商品编辑信息
```erb

```
  
OrderItem <=> Shipment
         
* Buyer
 
* Provider

## 注意
* Order: amount, received_amount
* Payment: total_amount, checked_amount
* PaymentOrder: check_amount

### 依赖
* [default_form](https://github.com/qinmingyuan/default_form)
* [default_where](https://github.com/qinmingyuan/default_where)
* [rails_audit](https://github.com/yougexiangfa/rails_audit)
* [rails_data](https://github.com/yougexiangfa/rails_data)
  * admin/payments
* [rails_role](https://github.com/yougexiangfa/rails_role)
  * admin/payments_controller
