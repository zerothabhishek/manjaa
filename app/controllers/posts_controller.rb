class PostsController < ApplicationController
  
  before_filter :authenticate_user!
  # GET /site/:site_id/posts
  # GET /site/:site_id/posts.xml
  def index
    @site = current_user.sites.find(params[:site_id])
    @posts = @site.posts.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /sites/:site_id/posts/:id
  # GET /sites/:site_id/posts/:id.xml
  def show
    @site = current_user.sites.find(params[:site_id])
    @post = @site.posts.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /sites/:site_id/posts/new
  # GET /sites/:site_id/posts/new.xml
  def new
    @site = current_user.sites.find(params[:site_id])
    @post = @site.posts.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /sites/:site_id/posts/:id/edit
  def edit
    @site = current_user.sites.find(params[:site_id])
    @post = @site.posts.find(params[:id])
  end

  # POST /sites/:site_id/posts
  # POST /sites/:site_id/posts.xml
  def create
    @site = current_user.sites.find(params[:site_id])
    @post = @site.posts.build(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to(site_post_path(@site, @post), :notice => 'Post was successfully created.') }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sites/:site_id/posts/:id
  # PUT /sites/:site_id/posts/:id.xml
  def update
    @site = current_user.sites.find(params[:site_id])
    @post = @site.posts.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to(site_post_path(@site, @post), :notice => 'Post was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/:site_id/posts/:id
  # DELETE /sites/:site_id/posts/:id.xml
  def destroy
    @site = current_user.sites.find(params[:site_id])
    @post = @site.posts.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to(site_posts_url(@site)) }
      format.xml  { head :ok }
    end
  end
end
