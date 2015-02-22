class Admin::BaseController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin

  def authenticate_admin

  end

end
