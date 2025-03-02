class UsersController < ApplicationController
  before_action :authenticate_user!
  
  def dashboard
    @urls = current_user.urls.order(created_at: :desc)
  end
end