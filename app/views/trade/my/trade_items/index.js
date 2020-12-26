import { Controller } from 'stimulus'

class CartController extends Controller {
  static targets = [ 'number' ]

  connect() {
    console.debug('Number is', this.number)
    console.debug('Cart Controller connected!')
  }

  update() {
    var data = new FormData()
    data.set(this.numberTarget.name, this.numberTarget.value)
    Rails.ajax({
      url: this.url,
      type: 'PATCH',
      dataType: 'script',
      data: data
    })
  }

  increase() {
    this.number = this.numberTarget.valueAsNumber + 1
    this.update()
  }

  decrease() {
    this.number = this.numberTarget.valueAsNumber - 1
    this.update()
  }

  set number(value) {
    this.numberTarget.value = value
  }

  get number() {
    return parseInt(this.numberTarget.value)
  }

  get url() {
    return this.numberTarget.dataset.url
  }
}

application.register('cart', CartController)
