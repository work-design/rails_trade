# TheTrade

This project rocks and uses MIT-LICENSE.


## 核心模型
 
* Good
 
可进行售卖，出租的实体，将其关联 good 即可处理。`Good`模型会处理涉及由可交易产生的信息，比如价格、促销方式等。

#### 流程  
Good -> CartItem -> Order(OrderItem) <=> Payment
  
```
Good
└ Promote
```
  
#### 集成商品编辑信息
```erb
<% if product.good %>
  <%= link_to admin_good_path(product.good.id), remote: true do %>
    <i class="shopping bag icon" id="good_<%= product.good.id %>"></i>
  <% end %>
<% else %>
  <%= link_to new_admin_good_path(sku: product.sku), remote: true do %>
    <i class="shop icon" id="product_<%= product.sku %>"></i>
  <% end %>
<% end %>
```
  
OrderItem <=> Shipment
         
* Buyer
 
 
* Provider
 