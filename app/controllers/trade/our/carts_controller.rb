module Trade
  class Our::CartsController < My::CartsController
    if whether_filter :require_client
      skip_before_action :require_client, only: [:list]
    end

    def addresses
      @addresses = current_client.addresses.order(id: :asc)
    end

    private
    def cart_params
      params.fetch(:cart, {}).permit(
        :address_id,
        :auto
      )
    end

  end
end
