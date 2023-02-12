module Trade
  class In::ItemsController < Admin::ItemsController
    before_action :set_item, only: [:show, :update, :destroy]
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

    def set_item
      q_params = {
        member_organ_id: current_organ.id
      }

      @item = Item.default_where(q_params).find params[:id]
    end

  end
end

