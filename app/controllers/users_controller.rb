class UsersController < ApplicationController
  before_action :find_user, only: [:show, :edit, :update, :destroy]
  def index
    @users = User.all
  end

  def new
    @user ||= User.new
  end

  def create
    @user = User.new params.require(:user).permit(:email, :name)
    if @user.save
      flash.now[:notice] = "User ##{@user.id} created!"
      redirect_to user_path(@user)
    else
      flash.now[:error] = "Errors: #{@user.errors.full_messages.join ', '}"
      redirect_to :back
    end
  end

  def show
  end

  def edit
  end

  def update
    user_params = params.require(:user).permit(:email, :name, :role)
    if @user.update user_params.merge(role: user_params[:role].to_i)
      flash.now[:notice] = "User ##{@user.id} updated!"
      redirect_to user_path(@user)
    else
      flash.now[:error] = "Errors: #{@user.errors.full_messages.join ', '}"
      redirect_to :back
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  private

  def find_user
    @user ||= User.find params[:id]
  end
end
