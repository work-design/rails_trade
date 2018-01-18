$('input[name="order[address_id]"]').change(function(){
  var search_path = window.location.search;
  var total_url;
  var query_data = {
    extra: {
      zone: this.dataset['zone']
    }
  };
  var query_result = $.param(query_data);
  if (this.checked) {
    total_url = '/admin/orders/refresh' + search_path + '&' + query_result;
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