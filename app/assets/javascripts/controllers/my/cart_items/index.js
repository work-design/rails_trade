function increase_quantity(){
  var x = parseInt($('#quantity').val());
  $('#quantity').val(x + 1);
}

function decrease_quantity(){
  var x = parseInt($('#quantity').val());
  $('#quantity').val(x - 1);
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
});