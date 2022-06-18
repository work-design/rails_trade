module Trade
  class In::TradeItemsController < Admin::TradeItemsController
    before_action :set_trade_item, only: [:show, :update, :destroy]
    before_action :set_new_trade_item, only: [:create, :cost]

    def cost
      @trade_item.single_price = @trade_item.good.cost
      @trade_item.save
    end

    private
    def set_new_trade_item
      options = {
        user_id: current_user.id,
        member_id: current_member.id
      }
      options.merge! params.permit(:good_type, :good_id, :current_cart_id, :number, :produce_on, :scene_id)

      @trade_item = TradeItem.new(options)
    end

    def set_trade_item
      q_params = {
        member_organ_id: current_organ.id
      }

      @trade_item = TradeItem.default_where(q_params).find params[:id]
    end

  end
end

