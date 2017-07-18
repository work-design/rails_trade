$('#q_buyer_type').dropdown();
$('#q_buyer_id').dropdown({
  apiSettings: {
    url: '/buyers/search?q={query}&buyer_type={buyer_type}',
    beforeSend: function(settings) {
      settings.urlData.buyer_type = document.querySelector('select[name="q[buyer_type]"]').value;
      return settings;
    }
  },
  fields: {
    name: 'name_detail',
    value: 'id'
  },
  minCharacters: 2
});