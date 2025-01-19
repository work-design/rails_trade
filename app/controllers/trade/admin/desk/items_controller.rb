module Trade::Admin
  class Desk::ItemsController < ItemsController
    before_action :set_desk

    def index
      q_params = {
        status: ['init', 'checked', 'ordered']
      }
      q_params.merge! default_params
      q_params.merge! params.permit(:cart_id, :order_id, :good_type, :good_id, :desk_id, :aim, :address_id, :status)

      @items = Item.includes(:user, :item_promotes, :order).default_where(q_params).order(order_id: :desc).page(params[:page]).per(params[:per])
    end

    def history
      q_params = {
        status: ['deliverable', 'done']
      }
      q_params.merge! default_params
      q_params.merge! params.permit(:cart_id, :order_id, :good_type, :good_id, :desk_id, :aim, :address_id, :status, 'created_at-gte', 'created_at-lte')

      @items = Item.includes(:good, :user, :item_promotes, :order).default_where(q_params).order(order_id: :desc).page(params[:page]).per(params[:per])
    end

    def done
      q_params = {
        status: 'ordered'
      }
      q_params.merge! default_params
      q_params.merge! params.permit(:cart_id, :order_id, :good_type, :good_id, :desk_id, :aim, :address_id, :status)

      @items = Item.default_where(q_params).update_all status: 'done'
    end

    private
    def set_desk
      @desk = Space::Desk.default_where(default_params).find params[:desk_id]
    end

  end
end
