class LikesController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource :post
  load_and_authorize_resource through: :post

  def index
  end

  def create
  end

  def destroy
  end
end
