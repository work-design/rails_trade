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
  var url = '/admin/cart_items/' + cart_item_id;
  var params = {
    method: 'PATCH',
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").content
    },
    body: JSON.stringify({
      quantity: q.val()
    })
  };
  fetch(url, params).then(function(response) {
    return response.text()
  }).then(function(response) {
    var script = document.createElement('script');
    script.text = response;
    document.head.appendChild(script).parentNode.removeChild(script);
  }).catch(function(ex) {
    console.log('parsing failed', ex)
  })
}

$('.xx_popup').popup({
  popup: '.ui.popup'
});



