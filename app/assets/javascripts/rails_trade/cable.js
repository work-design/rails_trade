ApplicationCable.subscriptions.create('PaidChannel', {
  received: function(data) {
    console.log('ssss')
    location.href = data.link;
  },
  connected: function() {
    console.log('done channel connected success');
  }
});
