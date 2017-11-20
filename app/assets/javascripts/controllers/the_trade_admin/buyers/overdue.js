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
$('#q_payment_strategy_id').dropdown();
$('#q_crm_permits\\.manager_id').dropdown();