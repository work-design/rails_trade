module Trade
  class My::CartsController < My::BaseController
    before_action :set_cart, only: [:show, :update]
    before_action :set_purchase, only: [:show, :invest, :rent]
    before_action :set_invest_cart, only: [:invest]
    before_action :set_rent_cart, only: [:rent]
    before_action :set_roles, only: [:list]

    def index
      q_params = {
        member_id: nil,
        aim: 'use',
        good_type: 'Factory::Production'
      }
      q_params.merge! default_params

      @carts = current_user.carts.where(q_params).order(updated_at: :desc).page(params[:page])
    end

    def show
      q_params = {}

      @items = @cart.items.includes(:delivery, produce_plan: :scene).default_where(q_params).order(id: :asc).page(params[:page])
      @checked_ids = @cart.items.default_where(q_params).unscope(where: :status).status_checked.pluck(:id)
    end

    def invest
      q_params = {
        good_type: 'Ship::BoxSpecification',
        aim: 'use'
      }

      @items = @cart.items.default_where(q_params).order(id: :asc).page(params[:page])
      @checked_ids = @cart.items.default_where(q_params).unscope(where: :status).status_checked.pluck(:id)
    end

    def rent
      q_params = {
        good_type: 'Ship::BoxSpecification',
        aim: 'rent'
      }

      @items = @cart.items.default_where(q_params).order(id: :asc).page(params[:page])
      @checked_ids = @cart.items.default_where(q_params).unscope(where: :status).status_checked.pluck(:id)
    end

    def addresses
      @addresses = current_user.addresses.order(id: :asc)
    end

    def list
      @members = current_user.members.includes(:organ)
    end

    def promote
    end

    def toggle_all

    end

    private
    def set_cart
      options = {}
      options.merge! default_form_params
      options.merge! user_id: current_user.id

      @cart = Cart.where(options).unscope(where: :organ_id).find params[:id]
      @cart.compute_amount! unless @cart.fresh
    end

    def set_invest_cart
      @cart = current_carts.find_by(good_type: 'Ship::BoxSpecification', aim: 'use')
    end

    def set_rent_cart
      @cart = current_carts.unscope(where: :organ_id).find_by(good_type: 'Ship::BoxSpecification', aim: 'rent')
    end

    def set_purchase
      @card_templates = @cart.available_card_templates
    end

    def set_roles
      if params[:role_id].present?
        @roles = Roled::OrganRole.visible.where(id: params[:role_id])
      else
        @roles = Roled::OrganRole.visible
      end
    end

    def cart_params
      params.fetch(:cart, {}).permit(
        :address_id,
        :auto
      )
    end

  end
end
