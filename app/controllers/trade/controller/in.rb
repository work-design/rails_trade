module Trade
  module Controller::In
    extend ActiveSupport::Concern
    include Controller::Application
    include Org::Controller::In

    included do
      layout -> { turbo_frame_body? ? 'frame/body' : 'admin' }
    end

    def set_new_item
      options = {}
      options.merge! params.permit(:good_id, :purchase_id, :produce_on, :scene_id)

      @item = @cart.organ_item(**options) || @cart.organ_items.build(options)
      @item.status = 'checked'
      @item.assign_attributes params.permit(['station_id', 'desk_id', 'current_cart_id'] & Item.column_names)
      @item.number = @item.number.to_i + (params[:number].presence || 1).to_i if @item.persisted?
    end

  end
end
