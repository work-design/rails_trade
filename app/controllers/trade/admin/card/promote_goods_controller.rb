module Trade
  class Admin::Card::PromoteGoodsController < Admin::PromoteGoodsController
    before_action :set_card
    before_action :set_promote_good, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_promote_good, only: [:new, :create]

    def index
      @promote_goods = @card.promote_goods
      @promotes = Promote.default_where(default_params)
    end

    private
    def set_card
      @card = Card.find params[:card_id]
    end

    def set_promote_good
      @promote_good = @card.promote_goods.default_where(default_params).find(params[:id])
    end

    def set_new_promote_good
      @promote_good = @card.promote_goods.build(promote_good_params)
    end

  end
end
