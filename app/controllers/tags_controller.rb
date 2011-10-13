class TagsController < BaseController
  before_filter :login_required, :only => [:manage, :edit, :update, :destroy]
  before_filter :admin_required, :only => [:manage, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => 'auto_complete_for_tag_name'

  caches_action :show, :cache_path => Proc.new { |controller| controller.send(:tag_url, controller.params[:id]) }, :if => Proc.new{|c| c.cache_action? }
  def cache_action?
    !logged_in? && params[:type].blank?
  end  

  def auto_complete_for_tag_name
    @tags = Tag.find(:all, :limit => 10, :conditions => [ 'LOWER(name) LIKE ?', '%' + (params[:id] || params[:tag_list]) + '%' ])
    render :inline => "<%= auto_complete_result(@tags, 'name') %>"
  end
  
  def index  
    @tags = popular_tags(100, ' count DESC')

    @user_tags = popular_tags(75, ' count DESC', 'User')

    @post_tags = popular_tags(75, ' count DESC', 'Post')

    @photo_tags = popular_tags(75, ' count DESC', 'Photo')

    @clipping_tags = popular_tags(75, ' count DESC', 'Clipping')  
  end
  
  def manage
    @search = Tag.search(params[:search])
    @search.order ||= :ascend_by_name
    @tags = @search.page(params[:page]).per(100)
  end
  

  def edit
    @tag = Tag.find_by_name(URI::decode(params[:id]))
  end

  def update
    @tag = Tag.find_by_name(URI::decode(params[:id]))
    
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = :tag_was_successfully_updated.l
        format.html { redirect_to admin_tags_url }
        format.xml  { render :nothing => true }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors.to_xml }        
      end
    end
  end

  def destroy
    @tag = Tag.find_by_name(URI::decode(params[:id]))
    @tag.destroy
    
    respond_to do |format|
      format.html { 
        flash[:notice] = :tag_was_successfully_deleted.l
        redirect_to admin_tags_url
      }
      format.xml  { render :nothing => true }
    end
  end

  def show
    tag_names = URI::decode(params[:id])
    
    @tags = Tag.find(:all, :conditions => [ 'name IN (?)', TagList.from(tag_names) ] )
    if @tags.nil? || @tags.empty?
      flash[:notice] = :tag_does_not_exists.l_with_args(:tag => tag_names)
      redirect_to :action => :index and return
    end
    @related_tags = @tags.collect { |tag| tag.related_tags }.flatten.uniq
    @tags_raw = @tags.collect { |t| t.name } .join(',')

    if params[:type]
      case params[:type]
        when 'Post', 'posts'
          @pages = @posts = Post.recent.find_tagged_with(tag_names, :match_all => true, :page => {:size => 20, :current => params[:page]})
          @photos, @users, @clippings = [], [], []
        when 'Photo', 'photos'
          @pages = @photos = Photo.recent.find_tagged_with(tag_names, :match_all => true, :page => {:size => 30, :current => params[:page]})
          @posts, @users, @clippings = [], [], []
        when 'User', 'users'
          @pages = @users = User.recent.find_tagged_with(tag_names, :match_all => true, :page => {:size => 30, :current => params[:page]})
          @posts, @photos, @clippings = [], [], []
        when 'Clipping', 'clippings'
          @pages = @clippings = Clipping.recent.find_tagged_with(tag_names, :match_all => true, :page => {:size => 10, :current => params[:page]})
          @posts, @photos, @users = [], [], []
      else
        @clippings, @posts, @photos, @users = [], [], [], []
      end
    else
      @posts = Post.recent.find_tagged_with(tag_names, :match_all => true, :limit => 5)
      @photos = Photo.recent.find_tagged_with(tag_names, :match_all => true, :limit => 10)
      @users = User.recent.find_tagged_with(tag_names, :match_all => true, :limit => 10).uniq
      @clippings = Clipping.recent.find_tagged_with(tag_names, :match_all => true, :limit => 10)
    end
  end

end
