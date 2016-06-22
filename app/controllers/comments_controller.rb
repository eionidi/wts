class CommentsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource

  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
