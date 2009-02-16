class SitemapController < BaseController
  layout false
  caches_action :index

  def index
    @users = User.active.find(:all, :select => 'id, login, updated_at, login_slug')
    @posts = Post.find(:all, :select => 'posts.id, posts.user_id, posts.title, posts.published_at, users.id, users.login_slug as user_slug', :joins => "LEFT JOIN users on users.id = posts.user_id")
  
    @categories = Category.find(:all)
  
    respond_to do |format|
      format.html {
        render :layout => 'application'
      }
      format.xml 
    end
  end
  
  
  
end
