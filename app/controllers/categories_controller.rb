class CategoriesController < BaseController
  before_filter :login_required, :except => [:show, :most_viewed, :rss]
  before_filter :admin_required, :only => [:new, :edit, :update, :create, :destroy, :index]
  
  # GET /categories
  # GET /categories.xml
  def index
    @categories = Category.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @categories.to_xml }
    end
  end
  
  # GET /categories/1
  # GET /categories/1.xml
  def show
    @category = Category.find(params[:id])
    @sidebar_right = true
    
    cond = Caboose::EZ::Condition.new
    cond.category_id  == @category.id
    order = (params[:popular] ? "view_count #{params[:popular]}": "published_at DESC")
    @pages, @posts = paginate :posts, :order => order, :conditions => cond.to_sql, :include => :tags
    
    @popular_posts = @category.posts.find(:all, :limit => 10, :order => "view_count DESC")
    @popular_polls = Poll.find_popular_in_category(@category)

    @rss_title = "#{AppConfig.community_name}: #{@category.name} posts"
    @rss_url = formatted_category_path(@category, :rss)

    @active_users = User.find(:all,
      :include => :posts,
      :limit => 5,
      :conditions => ["posts.category_id = ? AND posts.published_at > ?", @category.id, 14.days.ago],
      :order => "users.view_count DESC"
      )
    
    respond_to do |format|
      format.html # show.rhtml
      format.rss {
        render_rss_feed_for(@posts, {:feed => {:title => "#{AppConfig.community_name}: #{@category.name} posts", :link => category_url(@category)},
          :item => {:title => :title, :link => :link_for_rss, :description => :post, :pub_date => :published_at} })        
      }
    end
  end 
    
  # GET /categories/new
  def new
    @category = Category.new
  end
  
  # GET /categories/1;edit
  def edit
    @category = Category.find(params[:id])
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])
    
    respond_to do |format|
      if @category.save
        flash[:notice] = 'Category was successfully created.'
        
        format.html { redirect_to category_url(@category) }
        format.xml do
          headers["Location"] = category_url(@category)
          render :nothing => true, :status => "201 Created"
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors.to_xml }
      end
    end
  end
  
  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = Category.find(params[:id])
    
    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to category_url(@category) }
        format.xml  { render :nothing => true }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors.to_xml }        
      end
    end
  end
  
  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    
    respond_to do |format|
      format.html { redirect_to categories_url   }
      format.xml  { render :nothing => true }
    end
  end
  
  def show_tips
    @category = Category.find(params[:id] )
    render :partial => "/categories/tips", :locals => {:category => @category}
  rescue ActiveRecord::RecordNotFound
    render :partial => "/categories/tips", :locals => {:category => nil}
  end
  
  
end