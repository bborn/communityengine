class SitemapController < BaseController
  layout false
  caches_action :index

  def index
    @users = User.active.select('id', 'login', 'updated_at', 'login_slug')
    @posts = Post.select('posts.id', 'posts.user_id', 'posts.published_as', 'posts.published_at', 'users.id', 'users.login_slug').joins(:user)   #"LEFT JOIN users ON users.id = posts.user_id")

    @categories = Category.all

    respond_to do |format|
      format.html {
        render :layout => 'application'
      }
      format.xml
    end
  end



end
