class SitemapController < BaseController
  layout false
  caches_action :index  
  def cache_action?(action_name)
    true
  end  

  def index
    @users = User.find(:all, :select => 'id, login, updated_at, login_slug', :conditions => "activated_at IS NOT NULL")
    @posts = Post.find(:all, :select => 'id, title, created_at')
  
    @categories = Category.find(:all)
  
    respond_to do |format|
      format.html {
        render :layout => 'application'
      }
      format.xml
    end
  end
  
  
  
end
