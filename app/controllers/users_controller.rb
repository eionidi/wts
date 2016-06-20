class UsersController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource

  def index
    respond_to do |f|
      f.html
      f.json { render json: @users.as_json(only: %i(id email role name created_at)) }
    end
  end

  def show
  end

  def edit
  end

  def update
    user_params = params.require(:user).permit(:email, :name, :role)
    user_params = user_params.merge(role: user_params[:role].to_i) if user_params[:role].present?
    if @user.update user_params
      flash.now[:notice] = "User ##{@user.id} updated!"
      redirect_to user_path(@user)
    else
      flash.now[:error] = "Errors: #{@user.errors.full_messages.join ', '}"
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end
end
