class PostsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource

  def index
    @posts = @posts.order updated_at: :desc
  end

  def new
  end

  def create
    @post = Post.new post_params
    if @post.save
      flash.now[:notice] = "Post ##{@post.id} created!"
      redirect_to post_path(@post)
    else
      flash.now[:error] = "Errors: #{@post.errors.full_messages.join ', '}"
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @post.update post_params
      flash.now[:notice] = "Post ##{@post.id} updated!"
      redirect_to post_path(@post)
    else
      flash.now[:error] = "Errors: #{@post.errors.full_messages.join ', '}"
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :author_id, :image)
  end
end
