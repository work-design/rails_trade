import { Controller } from 'stimulus'

class CartController extends Controller {
  static targets = [ 'number' ];

  connect() {
    console.log(this.numberTarget.value)
  }

  update() {
    var data = new FormData();
    data.set(this.numberTarget.name, this.numberTarget.value);
    Rails.ajax({ url: this.numberTarget.dataset.url, type: 'PATCH', dataType: 'script', data: data })
  }

  increase() {
    this.numberTarget.value = this.numberTarget.valueAsNumber + 1;
    this.update()
  }

  decrease() {
    this.numberTarget.value = this.numberTarget.valueAsNumber - 1;
    this.update()
  }
}

application.register('cart', CartController);
