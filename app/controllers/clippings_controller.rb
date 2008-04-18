class ClippingsController < BaseController
  before_filter :login_required, :only => [:new, :edit, :update, :create, :destroy, :new_clipping]
  before_filter :find_user, :only => [:new, :edit, :index, :show]
  before_filter :require_current_user, :only => [:new, :edit, :update, :destroy]
  uses_tiny_mce(:options => AppConfig.default_mce_options, :only => [:show,:new_clipping])

  
  def site_index
    cond = Caboose::EZ::Condition.new
    if params[:tag_name]    
      cond.append ['tags.name = ?', params[:tag_name]]
    end
  
    cond.append ['created_at > ?', 4.weeks.ago] unless params[:recent]
    order = (params[:recent] ? "created_at DESC" : "clippings.favorited_count DESC")
    
    
    @pages, @clippings = paginate(:clippings, 
      :order => order, 
      :conditions => cond.to_sql, 
      :include => :tags, 
      :per_page => 30)
    
    @rss_title = "#{AppConfig.community_name}: #{params[:popular] ? 'Popular' : 'Recent'} Clippings"
    @rss_url = rss_site_clippings_path
    respond_to do |format|
      format.html
      format.rss {
        render_rss_feed_for(@clippings,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'clippings', :action => 'site_index') },           
             :item => {:title => :title_for_rss,
                       :description => :description_for_rss,
                       :link => :link_for_rss,
                       :pub_date => :created_at} })        
        
      }
    end    
    
  end

  # GET /clippings
  # GET /clippings.xml
  def index
    @user = User.find(params[:user_id])        

    cond = Caboose::EZ::Condition.new
    cond.user_id == @user.id
    if params[:tag_name]    
      cond.append ['tags.name = ?', params[:tag_name]]
    end

    @pages, @clippings = paginate :clippings, :order => "created_at DESC", :conditions => cond.to_sql, :include => :tags

    @tags = Clipping.tags_count :user_id => @user.id, :limit => 20
    @clippings_data = @clippings.collect {|c| [c.id, c.image_url, c.description, c.url ]  }            
    
    @rss_title = "#{AppConfig.community_name}: #{@user.login}'s clippings"
    @rss_url = formatted_user_clippings_path(@user,:rss)

    respond_to do |format|
      format.html # index.rhtml
      format.js { render :inline => @clippings_data.to_json }
      format.widget { render :template => 'clippings/widget', :layout => false }
      format.rss {
        render_rss_feed_for(@clippings,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'clippings', :action => 'index', :user_id => @user) },           
             :item => {:title => :title_for_rss,
                       :description => :description_for_rss,
                       :link => :url,
                       :pub_date => :created_at} })        
        
      }
    end
  end
  
  # GET /clippings/1
  # GET /clippings/1.xml
  def show
    @user = User.find(params[:user_id])        
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
      render :inline => "<h1>Sorry, there was an error fetching the images from the page you requested</h1><a href='#{params[:uri]}'>Go back...</a>"
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
    @user = User.find(params[:user_id])
    @clipping = @user.clippings.new
  end
  
  # GET /clippings/1;edit
  def edit
    @clipping = Clipping.find(params[:id])
    @user = User.find(params[:user_id])    
  end

  # POST /clippings
  # POST /clippings.xml
  def create
    @user = current_user
    @clipping = @user.clippings.new(params[:clipping])  
    @clipping.user = @user
    
    respond_to do |format|
      if @clipping.save!
        @clipping.tag_with(params[:tag_list] || '')     
        flash[:notice] = 'Clipping was successfully created.'
        format.html { 
          unless params[:user_id]
            redirect_to_url(@clipping.url) rescue redirect_to user_clipping_url(@user, @clipping) 
          else
            redirect_to user_clipping_url(@user, @clipping) 
          end
        }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # PUT /clippings/1
  # PUT /clippings/1.xml
  def update
    @user = User.find(params[:user_id])        
    @clipping = Clipping.find(params[:id])
    
    respond_to do |format|
      if @clipping.update_attributes(params[:clipping])
        @clipping.tag_with(params[:tag_list] || '')     
        format.html { redirect_to user_clipping_url(@user, @clipping) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  # DELETE /clippings/1
  # DELETE /clippings/1.xml
  def destroy
    @user = User.find(params[:user_id])        
    @clipping = Clipping.find(params[:id])
    @clipping.destroy
    
    respond_to do |format|
      format.html { redirect_to user_clippings_url(@user)   }
    end
  end
end