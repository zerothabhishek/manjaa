class PostsController < ApplicationController
  
  def index
    @posts = current_user.posts.all
  end
  
  def show
    @post = current_user.posts.find params[:id]
  end
  
  def new
    @post = current_user.posts.build
  end
  
  def create
    @post = current_user.posts.build params[:post]
    if @post.save
      redirect_to post_path(@post)
    else
      render :action => "new"
    end
  end

  def edit
    @post = current_user.posts.find params[:id]
  end
  
  def update
    @post = current_user.posts.find params[:id]
    if @post.update_attributes(params[:post])
      @post.unpublished!
      redirect_to post_path(@post)
    else
      render :action => "edit"
    end
  end
  
  def publish
    @post = current_user.posts.find params[:id]
    @post.do_publish
    redirect_to post_path(@post)
  end
  
  def destroy
    @post = current_user.posts.find params[:id]
    @post.do_remove
    @post.destroy
    redirect_to posts_url
  end
  
end
