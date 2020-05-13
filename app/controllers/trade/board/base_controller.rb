class Trade::Board::BaseController < RailsTrade.config.board_controller.constantize

  def set_cart
    if current_session_organ
      @cart = current_user.carts.find_or_create_by(organ_id: current_session_organ.id)
    else
      @cart = current_user.total_cart || current_user.create_total_cart
    end
  end

end
