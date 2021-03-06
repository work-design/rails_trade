module Trade
  class Admin::CartsController < Admin::BaseController
    before_action :set_cart, only: [:show]

    def index
      q_params = {}
      q_params.merge! default_params

      @carts = Cart.default_where(q_params).page(params[:page])
    end

    def single
    end

    def total
    end

    def new
      @cart_serve = @cart_item.cart_serves.find_or_initialize_by(serve_id: params[:serve_id])
      @serve_charge = @cart_item.get_charge(@cart_serve.serve)
    end

    def create
      @cart_item_serve = @cart_item.cart_item_serves.find_or_initialize_by(serve_id: cart_item_serve_params[:serve_id])
      @cart_item_serve.assign_attributes cart_item_serve_params

      @serve_charge = @cart_item.get_charge(@cart_item_serve.serve)
      @serve_charge.subtotal = @cart_item_serve.price

      if @cart_item_serve.save

      else
        render :new
      end
    end

    def add
      @cart_item_serve = @cart_item.cart_item_serves.find_or_initialize_by(serve_id: params[:serve_id])

      @serve_charge = @cart_item.get_charge(@cart_item_serve.serve)
      @cart_item_serve.price = @serve_charge.default_subtotal
      @cart_item_serve.save
    end

    def show
    end

    def orders
      @orders = @buyer.orders.includes(crm_performs: :manager).to_pay.order(overdue_date: :asc).page(params[:page])
      payment_method_ids = @buyer.payment_references.pluck(:payment_method_id)
      @payments = Payment.where(payment_method_id: payment_method_ids, state: ['init', 'part_checked'])
    end


    def destroy
      @cart_item_serve = CartItem.find(params[:id])
      @serve_charge = @cart_item.get_charge(@cart_item_serve.serve)
      @cart_item_serve.destroy
    end

    private
    def set_cart
      @cart = Cart.find params[:id]
    end

    def cart_params
      params.fetch(:cart, {}).permit(
        :serve_id,
        :price
      )
    end

  end
end
