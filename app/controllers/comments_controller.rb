require 'my_artec_checker'

class CommentsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource :post
  load_and_authorize_resource through: :post

  skip_load_resource only: %i(create)

  def new
  end

  def create
    @comment = @post.comments.new params.require(:comment).permit(:content, :file_attach)
    @comment.assign_attributes author: current_user
    if @comment.save
      flash.now[:notice] = "Comment ##{@comment.id} created!"
      redirect_to post_path(@post)
    else
      flash.now[:error] = "Errors: #{@comment.errors.full_messages.join ', '}"
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @comment.update params.require(:comment).permit(:content)
      @comment.update last_updated_by: current_user
      flash.now[:notice] = "Comment ##{@comment.id} updated!"
      redirect_to post_path(@post)
    else
      flash.now[:error] = "Errors: #{@comment.errors.full_messages.join ', '}"
      render :edit
    end
  end

  def destroy
    @comment.destroy
    flash.now[:notice] = "Comment ##{@comment.id} destroyed!"
    redirect_to post_path(@post)
  end
end
