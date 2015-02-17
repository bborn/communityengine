class CategoriesController < BaseController
  before_action :login_required, :except => [:show, :most_viewed, :rss]


  # GET /categories/1
  # GET /categories/1.xml
  def show
    @category = Category.find(params[:id])

    order = (params[:popular] ? "view_count #{params[:popular].eql?('DESC') ? 'DESC' : 'ASC'}": "published_at DESC")

    @posts = Post.includes(:tags).where('category_id = ?', @category.id).order(order).page(params[:page])

    @popular_posts = @category.posts.order("view_count DESC").limit(10)
    @popular_polls = Poll.find_popular_in_category(@category)

    @rss_title = "#{configatron.community_name}: #{@category.name} "+:posts.l
    @rss_url = category_path(@category, :format => :rss)

    @active_users = User.includes(:posts).where("posts.category_id = ? AND posts.published_at > ?", @category.id, 14.days.ago).references(:posts).limit(5).order("users.view_count DESC").to_a

    respond_to do |format|
      format.html # show.rhtml
      format.rss {
        render_rss_feed_for(@posts, {:feed => {:title => "#{configatron.community_name}: #{@category.name} "+:posts.l, :link => category_url(@category)},
          :item => {:title => :title,
                    :link =>  Proc.new {|post| user_post_url(post.user, post)},
                    :description => :post,
                    :pub_date => :published_at} })
      }
    end
  end


  def show_tips
    @category = Category.find(params[:id] )
    render :partial => "/categories/tips", :locals => {:category => @category}
  rescue ActiveRecord::RecordNotFound
    render :partial => "/categories/tips", :locals => {:category => nil}
  end


end
