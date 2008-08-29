class TagsController < BaseController
  skip_before_filter :verify_authenticity_token, :only => 'auto_complete_for_tag_name'
    
  def auto_complete_for_tag_name
    @tags = Tag.find_list(params[:id] || params[:tag_list])
    render :inline => "<%= auto_complete_result(@tags, 'name') %>"
  end
  
  def index  
    @tags = popular_tags(100, ' count DESC')

    @user_tags = popular_tags(75, ' count DESC', 'User')

    @post_tags = popular_tags(75, ' count DESC', 'Post')

    @photo_tags = popular_tags(75, ' count DESC', 'Photo')

    @clipping_tags = popular_tags(75, ' count DESC', 'Clipping')  
  end
  
  def show
    @tag = Tag.find_by_name(params[:id])
    if @tag.nil? 
      flash[:notice] = :tag_does_not_exists.l_with_args(:tag => params[:id]) 
      redirect_to :action => :index and return
    end
    @related_tags = @tag.related_tags
    
    if params[:type]
      case params[:type]
        when 'Post'
          @pages = @photos = Post.recent.tagged_with(@tag.name).find(:all, :page => {:size => 20, :current => params[:page]})
          @photos, @users, @clippings = [], [], []
        when 'Photo'
          @pages = @photos = Photo.recent.tagged_with(@tag.name).find(:all, :page => {:size => 30, :current => params[:page]})
          @posts, @users, @clippings = [], [], []          
        when 'User'
          @pages = @users = User.recent.tagged_with(@tag.name).find(:all, :page => {:size => 30, :current => params[:page]})
          @posts, @photos, @clippings = [], [], []
        when 'Clipping'
          @pages = @clippings = Clipping.recent.find(:all, :page => {:size => 1, :current => params[:page]})
          @posts, @photos, @users = [], [], []          
        end
    else
      @posts = Post.recent.tagged_with(@tag.name).find(:all, :limit => 5)
      @photos = Photo.recent.tagged_with(@tag.name).find(:all, :limit => 10)
      @users = User.recent.tagged_with(@tag.name).find(:all, :limit => 10).uniq
      @clippings = Clipping.recent.tagged_with(@tag.name).find(:all, :limit => 10)
    end
  end

end
