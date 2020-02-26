$('#promote_charge_type').dropdown({
  onChange: function(value, text, $selectedItem){
    var search_url = new URL('admin/promote_charges/options', location.origin);
    search_url.searchParams.set('type', value);
    Rails.ajax({url: search_url, type: 'GET', dataType: 'script'});
  }
});
