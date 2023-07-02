module Trade
  class In::ItemsController < My::ItemsController
    before_action :set_item, only: [:show]
    before_action :set_new_item, only: [:create, :cost]

    def cost
      @item.single_price = @item.good.cost
      @item.save
    end

    private
    def set_new_item
      options = {
        member_id: current_member.id
      }
      options.merge! params.permit(:good_type, :good_id, :current_cart_id, :number, :produce_on, :scene_id, :member_id)

      @item = Item.new(options)
    end

    def set_cart_item
      @item = @cart.organ_items.load.find params[:id]
    end

  end
end

