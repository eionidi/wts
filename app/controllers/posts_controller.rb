class PostsController < ApplicationController
  before_action :find_post, only: %i(show edit update destroy)

  def index
    @posts = Post.all.order updated_at: :desc
  end

  def new
    @post ||= Post.new
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

  def find_post
    @post ||= Post.find params[:id]
  end

  def post_params
    params.require(:post).permit(:title, :content, :author_id)
  end
end
