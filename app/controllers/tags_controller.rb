class TagsController < BaseController
  before_filter :login_required, :only => [:manage, :edit, :update, :destroy]
  before_filter :admin_required, :only => [:manage, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => 'auto_complete_for_tag_name'

  caches_action :show, :cache_path => Proc.new { |controller| controller.send(:tag_url, controller.params[:id]) }, :if => Proc.new{|c| c.cache_action? }
  def cache_action?
    !logged_in? && params[:type].blank?
  end  

  def auto_complete_for_tag_name
    @tags = ActsAsTaggableOn::Tag.where('LOWER(name) LIKE ?', '%' + (params[:id] || params[:tag_list]) + '%').limit(10).all
    render :inline => "<%= auto_complete_result(@tags, 'name') %>"
  end
  
  def index  
    @tags = popular_tags(100)

    @user_tags = popular_tags(75, 'User')
    
    @post_tags = popular_tags(75, 'Post')

    @photo_tags = popular_tags(75, 'Photo')

    @clipping_tags = popular_tags(75, 'Clipping')  
  end
  
  def manage    
    @search = ActsAsTaggableOn::Tag.search(params[:search])
    @search.meta_sort ||= 'name.asc'    
    @tags = @search.page(params[:page]).per(100)
  end
  

  def edit
    @tag = ActsAsTaggableOn::Tag.find_by_name(URI::decode(params[:id]))
  end

  def update
    @tag = ActsAsTaggableOn::Tag.find_by_name(URI::decode(params[:id]))
    
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
    @tag = ActsAsTaggableOn::Tag.find_by_name(URI::decode(params[:id]))
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
    tag_array = ActsAsTaggableOn::TagList.from( URI::decode(params[:id]) )
    
    @tags = ActsAsTaggableOn::Tag.where('name IN (?)', tag_array).all
    if @tags.nil? || @tags.empty?
      flash[:notice] = :tag_does_not_exists.l_with_args(:tag => tag_array)
      redirect_to :action => :index and return
    end
    @related_tags = @tags.first.related_tags
    @tags_raw = @tags.collect { |t| t.name } .join(',')

    if params[:type]
      case params[:type]
        when 'Post', 'posts'
          @pages = @posts = Post.recent.tagged_with(tag_array).page(params[:page]).per(20)
          @photos, @users, @clippings = [], [], []
        when 'Photo', 'photos'
          @pages = @photos = Photo.recent.tagged_with(tag_array).page(params[:page]).per(30)
          @posts, @users, @clippings = [], [], []
        when 'User', 'users'
          @pages = @users = User.recent.tagged_with(tag_array).page(params[:page]).per(30)
          @posts, @photos, @clippings = [], [], []
        when 'Clipping', 'clippings'
          @pages = @clippings = Clipping.recent.tagged_with(tag_array).page(params[:page]).per(10)
          @posts, @photos, @users = [], [], []
      else
        @clippings, @posts, @photos, @users = [], [], [], []
      end
    else
      @posts      = Post.recent.limit(5).tagged_with(tag_array)
      @photos     = Photo.recent.limit(10).tagged_with(tag_array)
      @users      = User.recent.limit(10).tagged_with(tag_array)
      @clippings  = Clipping.recent.limit(10).tagged_with(tag_array)
    end
  end

end
