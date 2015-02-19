class TagsController < BaseController
  skip_before_action :verify_authenticity_token, :only => [:auto_complete_for_tag_name]

  caches_action :show, :cache_path => Proc.new { |controller| controller.send(:tag_url, controller.params[:id]) }, :if => Proc.new{|c| c.cache_action? }
  def cache_action?
    !logged_in? && params[:type].blank?
  end

  def auto_complete_for_tag_name
    @tag_names = ActsAsTaggableOn::Tag.pluck(:name)
    respond_to do |format|
      format.json {render :inline => @tag_names.to_json}
    end
  end

  def index
    @tags = popular_tags(100).to_a

    @user_tags = popular_tags(75, 'User').to_a

    @post_tags = popular_tags(75, 'Post').to_a

    @photo_tags = popular_tags(75, 'Photo').to_a

    @clipping_tags = popular_tags(75, 'Clipping').to_a
  end


  def show
    tag_array = ActsAsTaggableOn::DefaultParser.new( URI::decode(params[:id]) ).parse

    @tags = ActsAsTaggableOn::Tag.where('name IN (?)', tag_array )
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
