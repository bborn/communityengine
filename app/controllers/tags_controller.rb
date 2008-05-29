class TagsController < BaseController

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
      flash[:notice] = "The tag #{params[:id]} does not exist."
      redirect_to :action => :index and return
    end
    @related_tags = @tag.related_tags
    
    if params[:type]
      cond = Caboose::EZ::Condition.new
      cond.append ['tags.name = ?', @tag.name]

      case params[:type]
        when 'Post'
          @pages, @posts = paginate :posts, :order => "published_at DESC", :conditions => cond.to_sql, :include => :tags, :per_page => 20
          @photos, @users, @clippings = [], [], []
        when 'Photo'
          @pages, @photos = paginate :photos, :order => "created_at DESC", :conditions => cond.to_sql, :include => :tags, :per_page => 30
          @posts, @users, @clippings = [], [], []          
        when 'User'
          @pages, @users = paginate :users, :order => "created_at DESC", :conditions => cond.to_sql, :include => :tags, :per_page => 30
          @posts, @photos, @clippings = [], [], []
        when 'Clipping'
          @pages, @clippings = paginate :clippings, :order => "created_at DESC", :conditions => cond.to_sql, :include => :tags, :per_page => 30      
          @posts, @photos, @users = [], [], []          
        end
    else
      @posts = Post.find_tagged_with(@tag.name, :limit => 5, :order => 'published_at DESC', :sql => " AND published_as = 'live'")
      @photos = Photo.find_tagged_with(@tag.name, :limit => 10, :order => 'created_at DESC')
      @users = User.find_tagged_with(@tag.name, :limit => 10, :order => 'created_at DESC').uniq
      @clippings = Clipping.find_tagged_with(@tag.name, :limit => 10, :order => 'created_at DESC')
    end
  end

end
