class Admin::BaseController < ApplicationController
  #before_action :require_login
  before_action :require_role

  def current_user
    User.new
  end

end
