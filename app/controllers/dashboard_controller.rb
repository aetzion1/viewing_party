class DashboardController < ApplicationController
  def index
    return not_logged_in_notice unless current_user

    flash.now[:success] = "Welcome, #{current_user.name}"
    current_user
  end

  private

  def not_logged_in_notice
    flash[:notice] = 'You Must Log In To Visit Your Dashboard'
    redirect_to login_path
  end
end
