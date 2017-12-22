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
  var search_path = window.location.search;
  var total_url;
  if (this.checked) {
    total_url = '/admin/cart_items/total' + search_path + '&add_id=' + this.value;
  } else {
    total_url = '/admin/cart_items/total' + search_path + '&remove_id=' + this.value;
  }
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

$('#user_id').dropdown({
  onChange: function(value, text, $selectedItem){
    var path = new URL(window.location.href);
    path.searchParams.delete('good_type');
    path.searchParams.delete('good_id');
    console.log(path)
    path.searchParams.set('user_id', value);
    window.location.href = path;
  }
});

