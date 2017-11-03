$('#q_buyer_id').dropdown({
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
  minCharacters: 2
});