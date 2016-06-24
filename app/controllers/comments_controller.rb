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
    @post = @post.includes :comments
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
