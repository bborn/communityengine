class ClippingsController < BaseController
  before_filter :login_required, :only => [:new, :edit, :update, :create, :destroy, :new_clipping]
  before_filter :find_user, :only => [:new, :edit, :index, :show]
  before_filter :require_current_user, :only => [:new, :edit, :update, :destroy]

  uses_tiny_mce do
    {:only => [:show,:new_clipping], :options => configatron.default_mce_options}    
  end

  cache_sweeper :taggable_sweeper, :only => [:create, :update, :destroy]    

  def site_index
    @clippings = Clipping.includes(:tags).order(params[:recent] ? "created_at DESC" : "clippings.favorited_count DESC")
    
    @clippings = @clippings.where('tags.name = ?', params[:tag_name]).references(:tags) if params[:tag_name]
    @clippings = @clippings.where('created_at > ?', 4.weeks.ago) unless params[:recent]

    @clippings = @clippings.page(params[:page])

    @rss_title = "#{configatron.community_name}: #{params[:popular] ? :popular.l : :recent.l} "+:clippings.l
    @rss_url = rss_site_clippings_path
    respond_to do |format|
      format.html
      format.rss {
        render_rss_feed_for(@clippings,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'clippings', :action => 'site_index') },
             :item => {:title => :title_for_rss,
                       :description => Proc.new {|clip| description_for_rss(clip)},
                       :link => Proc.new {|clip| user_clipping_url(clip.user, clip)},
                       :pub_date => :created_at} })

      }
    end

  end

  # GET /clippings
  # GET /clippings.xml
  def index
    @user = User.friendly.find(params[:user_id])

    @clippings = Clipping.includes(:tags).where(:user_id => @user.id).order("clippings.created_at DESC")

    @clippings = @clippings.where('tags.name = ?', params[:tag_name]) if params[:tag_name]

    @clippings = @clippings.page(params[:page])
    
    @tags = Clipping.includes(:taggings).where(:user_id => @user.id).tag_counts(:limit => 20)    
    
    @clippings_data = @clippings.collect {|c| [c.id, c.image_url, c.description, c.url ]  }

    @rss_title = "#{configatron.community_name}: #{@user.login}'s clippings"
    @rss_url = user_clippings_path(@user,:format => :rss)

    respond_to do |format|
      format.html # index.rhtml
      format.js { render :inline => @clippings_data.to_json }
      # format.widget { render :template => 'clippings/widget', :layout => false }
      format.rss {
        render_rss_feed_for(@clippings,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'clippings', :action => 'index', :user_id => @user) },
             :item => {:title => :title_for_rss,
                       :description => Proc.new {|clip| description_for_rss(clip)},
                       :link => :url,
                       :pub_date => :created_at} })

      }
    end
  end

  # GET /clippings/1
  # GET /clippings/1.xml
  def show
    @user = User.friendly.find(params[:user_id])
    @clipping = Clipping.find(params[:id])
    @previous = @clipping.previous_clipping
    @next = @clipping.next_clipping

    @related = Clipping.find_related_to(@clipping)

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  def load_images_from_uri
    uri = URI.parse(params[:uri])
    begin
      doc = Hpricot( open( uri ) )
    rescue
      return
    end
    @page_title = (doc/"title")
    # get the images
    @images = []
    (doc/"img").each do |img|
      begin
        if URI.parse(URI.escape(img['src'])).scheme.nil?
          img_uri = "#{uri.scheme}://#{uri.host}/#{img['src']}"
        else
          img_uri = img['src']
        end
        @images << img_uri
      rescue
        nil
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def new_clipping
    @user = current_user
    @clipping = @user.clippings.new({:url => params[:uri], :description => params[:selection]})
    @post = @user.posts.new_from_bookmarklet(params)
    render :action => "new_clipping", :layout => false
  end

  # GET /clippings/new
  def new
    @user = User.friendly.find(params[:user_id])
    @clipping = @user.clippings.new
  end

  # GET /clippings/1;edit
  def edit
    @clipping = Clipping.find(params[:id])
    @user = User.friendly.find(params[:user_id])
  end

  # POST /clippings
  # POST /clippings.xml
  def create
    @user = current_user
    @clipping = @user.clippings.new(clipping_params)
    @clipping.user = @user
    @clipping.tag_list = params[:tag_list] || ''

    respond_to do |format|
      if @clipping.save!
        flash[:notice] = :clipping_was_successfully_created.l
        format.html {
          unless params[:user_id]
            redirect_to @clipping.url rescue redirect_to user_clipping_url(@user, @clipping)
          else
            redirect_to user_clipping_url(@user, @clipping)
          end
        }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # patch /clippings/1
  # patch /clippings/1.xml
  def update
    @user = User.friendly.find(params[:user_id])
    @clipping = Clipping.find(params[:id])
    @clipping.tag_list = params[:tag_list] || ''

    if @clipping.update_attributes(clipping_params)
      respond_to do |format|
        format.html { redirect_to user_clipping_url(@user, @clipping) }
      end
    else
      respond_to do |format|      
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /clippings/1
  # DELETE /clippings/1.xml
  def destroy
    @user = User.friendly.find(params[:user_id])
    @clipping = Clipping.find(params[:id])
    @clipping.destroy

    respond_to do |format|
      format.html { redirect_to user_clippings_url(@user)   }
    end
  end

  protected

  def description_for_rss(clip)
    "<a href='#{user_clipping_url(clip.user, clip)}' title='#{clip.title_for_rss}'><img src='#{clip.image_url}' alt='#{clip.description}' /></a>"
  end

  private

  def clipping_params
    params.require(:clipping).permit(:url, :description, :image_url, :image, :user, :user_id)
  end
end
