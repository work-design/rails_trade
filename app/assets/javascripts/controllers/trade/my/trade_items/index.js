class CartController extends Stimulus.Controller {
  static targets = [ 'number' ]

  increase() {
    this.numberTarget.value += 1
  }

  decrease() {
    this.numberTarget.value -= 1
  }

  update() {
    var q = $('#quantity_' + cart_item_id);
    var url = '/my/cart_items/' + cart_item_id;

    Rails.ajax({ url: url, type: 'PATCH', dataType: 'script', data: body })
  }
}

application.register('cart', CartController);
