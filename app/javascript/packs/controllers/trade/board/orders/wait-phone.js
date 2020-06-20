ApplicationCable.subscriptions.create('PaidChannel', {
  received: function(data) {
    location.href = data.link
  },
  connected: function() {
    console.log('PaidChannel connected success')
  }
})
