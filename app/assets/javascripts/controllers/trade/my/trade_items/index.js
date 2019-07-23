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

$('input[name="cart_item_id"]').change(function(){
  var total_url;
  if (this.checked) {
    total_url = '/my/cart_items/total' + '?add_id=' + this.value;
  } else {
    total_url = '/my/cart_items/total' + '?remove_id=' + this.value;
  }

  Rails.ajax({ url: total_url, type: 'GET', dataType: 'script' })
});


