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

function getCheckedIds() {
  var ids = [];
  $('input[name="cart_item_id"]:checked').each(function(){
    ids.push($(this).val())
  });
  ids = ids.join(',');
  return ids
}

$('input[name="cart_item_id"]').change(function(){
  var remind_link = new URL($('#new_order')[0].href);
  $('#new_order').attr('href', remind_link.pathname + '?cart_item_ids=' + getCheckedIds());

  var search_path = window.location.search;
  var total_url = '/admin/cart_items/total' + search_path + '&cart_item_ids=' + getCheckedIds();
  var params = {
    credentials: 'include',
    headers: {
      'Accept': 'application/javascript',
      'X-CSRF-Token': document.head.querySelector("[name=csrf-token]").content
    }
  };
  fetch(total_url, params).then(function(response) {
    return response.text()
  }).then(function(response) {
    var script = document.createElement('script');
    script.text = response;
    document.head.appendChild(script).parentNode.removeChild(script);
  }).catch(function(ex) {
    console.log('parsing failed', ex)
  })
});

$('.xx_popup').popup({
  popup: '.ui.popup'
});

