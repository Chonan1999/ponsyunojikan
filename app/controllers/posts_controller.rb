class PostsController < ApplicationController
  before_action :authenticate_user!

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.new(post_params)
    @post.user_id = current_user.id
    if @post.save
      redirect_to posts_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def publish
    if @post.draft? # 下書き状態か確認
      @post.update(status: "published") # ステータスをpublishedに変更
      redirect_to @post, notice: "下書きを投稿しました！"
    else
      redirect_to @post, alert: "この投稿は既に公開されています。"
    end
  end

  def index
    @posts = Post.published.order(created_at: :desc).page(params[:page])
  end

  def show
    @post = Post.find(params[:id])
    @user = @post.user 
    @recent_posts = @user.posts.order(created_at: :desc).limit(6)
    @comments = @post.comments
    @comments = @post.comments
  end

  def edit
    @post = Post.find(params[:id])
  end

  def confirm
    @drafts = Post.where(status: "draft").order(created_at: :desc)
  end

  def update
    post = Post.find(params[:id])
    post.update(post_params)
    redirect_to post_path(post.id)
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy
    redirect_to posts_path
  end

  private
  def post_params
    params.require(:post).permit(:name, :text, :image, :status)
  end

  def set_post
    @post = Post.find(params[:id])
  end
end
