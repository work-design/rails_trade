# TheTrade

This project rocks and uses MIT-LICENSE.


## 核心模型
 
* Good
 
可进行售卖，出租的实体，将其关联 good 即可处理。`Good`模型会处理涉及由可交易产生的信息，比如价格、促销方式等。

#### 流程  
Good -> CartItem -> Order(OrderItem) <=> Payment
  
Good
└ Promote
  
OrderItem <=> Shipment
         
* Buyer
 
 
* Provider
 