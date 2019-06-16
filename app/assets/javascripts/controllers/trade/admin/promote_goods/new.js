$('#promote_good_good_type').dropdown({
  onChange: function (value, text, $selectedItem) {
    var search_url = new URL(window.location.origin);
    search_url.pathname = 'admin/promote_goods/goods';
    search_url.search = $.param({good_type: value});

    Rails.ajax({
      url: search_url,
      type: 'GET',
      dataType: 'script'
    })
  }
})
$('#promote_good_good_id').dropdown({
  placeholder: false
});
