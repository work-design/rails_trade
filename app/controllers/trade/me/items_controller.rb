module Trade
  class Me::ItemsController < My::ItemsController
    include Controller::Me

    def index
      @items = current_member.items.order(id: :desc).page(params[:page])
    end

    private
    def set_cart
      options = {}
      options.merge! default_form_params
      options.merge! member_id: current_member.id
      @cart = Cart.where(options).find_or_create_by(good_type: params[:good_type], aim: params[:aim].presence || 'use')
    end

    def set_item
      @item = current_member.items.find params[:id]
    end

  end
end

