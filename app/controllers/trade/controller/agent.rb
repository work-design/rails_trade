module Trade
  module Controller::Agent
    extend ActiveSupport::Concern
    include Controller::Application

    included do
      #layout 'agent'
    end

    def set_new_item
      options = { agent_id: current_member.id }
      options.merge! params.permit(:good_id, :produce_on, :scene_id)
      options.compact_blank!

      @item = @cart.find_item(**options) || @cart.items.build(options)
      @item.status = 'checked'
      @item.assign_attributes params.permit(['station_id', 'desk_id', 'current_cart_id'] & Item.column_names)
      @item.number = @item.number.to_i + (params[:number].presence || 1).to_i if @item.persisted?
    end

    class_methods do
      def local_prefixes
        [controller_path, 'agent', 'me']
      end
    end

  end
end
