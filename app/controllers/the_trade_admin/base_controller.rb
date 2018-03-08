class TheTradeAdmin::BaseController < TheTrade.config.admin_class.constantize
  default_form_builder 'TheTradeAdminFormBuilder'


  def administrator
    current_user
  end
  
end
