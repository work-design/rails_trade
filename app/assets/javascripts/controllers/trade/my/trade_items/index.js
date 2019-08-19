function increase_quantity(cart_item_id){
  var q = $('#quantity_' + cart_item_id);
  var x = parseInt(q.val());
  q.val(x + 1);
  update_quantity(cart_item_id);
}

function decrease_quantity(cart_item_id){
  var q = $('#quantity_' + cart_item_id);
  var x = parseInt(q.val());
  q.val(x - 1);
  update_quantity(cart_item_id);
}

function update_quantity(cart_item_id){
  var q = $('#quantity_' + cart_item_id);
  var url = '/my/cart_items/' + cart_item_id;
  var body = JSON.stringify({
    quantity: q.val()
  })

  Rails.ajax({ url: url, type: 'PATCH', dataType: 'script', data: body })
}
