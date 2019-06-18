$('#promote_buyer_buyer_type').dropdown();
$('#promote_buyer_buyer_id').dropdown({
  apiSettings: {
    url: '/buyers/search?q={query}',
    beforeSend: function(settings) {
      return settings;
    }
  },
  fields: {
    name: 'name_detail',
    value: 'id'
  },
  filterRemoteData: false,
  saveRemoteData: true,
  minCharacters: 2
});

$('#promote_buyer_promote_id').dropdown({
  apiSettings: {
    url: '/admin/promotes/search?q={query}',
    beforeSend: function(settings) {
      return settings;
    }
  },
  fields: {
    name: 'name',
    value: 'id'
  },
  filterRemoteData: false,
  saveRemoteData: true,
  minCharacters: 2
});
