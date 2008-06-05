require 'pp'

class PhotosController < BaseController
  before_filter :login_required, :only => [:new, :edit, :update, :destroy, :create, :manage_photos, :swfupload]
  before_filter :find_user, :only => [:new, :edit, :index, :show, :slideshow, :swfupload]
  before_filter :require_current_user, :only => [:new, :edit, :update, :destroy, :swfupload]

  skip_before_filter :verify_authenticity_token, :only => :create #because the TinyMCE image uploader can't provide the auth token
  
  session :cookie_only => false, :only => :swfupload  
  
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:show])
  
  def recent
    @pages, @photos = paginate :photo, :order => "created_at DESC", :conditions => ["parent_id IS NULL"]
  end
  
  # GET /photos
  # GET /photos.xml
  def index
    @user = User.find(params[:user_id])        
    
    cond = Caboose::EZ::Condition.new
    cond.user_id == @user.id
    if params[:tag_name]    
      cond.append ['tags.name = ?', params[:tag_name]]
    end

    @pages, @photos = paginate :photos, :order => "created_at DESC", :conditions => cond.to_sql, :include => :tags

    @tags = Photo.tags_count :user_id => @user.id, :limit => 20

    @rss_title = "#{AppConfig.community_name}: #{@user.login}'s photos"
    @rss_url = formatted_user_photos_path(@user,:rss)

    respond_to do |format|
      format.html # index.rhtml
      format.rss {
        render_rss_feed_for(@photos,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'photos', :action => 'index', :user_id => @user) },           
             :item => {:title => :name,
                       :description => :description_for_rss,
                       :link => :link_for_rss,
                       :pub_date => :created_at} })        
        
      }
      format.xml { render :action => 'index.rxml', :layout => false}        
    end
  end
  
  def manage_photos
    @user = current_user
    cond = Caboose::EZ::Condition.new
    cond.user_id == @user.id
    if params[:tag_name]    
      cond.append ['tags.name = ?', params[:tag_name]]
    end
    
    @selected = params[:photo_id]
    @pages, @photos = paginate :photos, :order => "created_at DESC", :conditions => cond.to_sql, :include => :tags, :per_page => 10
    respond_to do |format|
      format.js
    end
  end
  
  # GET /photos/1
  # GET /photos/1.xml
  def show
    @photo = Photo.find(params[:id])
    @user = @photo.user
    @is_current_user = @user.eql?(current_user)
    @comment = Comment.new(params[:comment])

    @previous = @photo.previous_photo
    @next = @photo.next_photo
    @related = Photo.find_related_to(@photo)
        
    respond_to do |format|
      format.html # show.rhtml
    end
  end
  
  # GET /photos/new
  def new    
    @user = User.find(params[:user_id])    
    @photo = Photo.new
    if params[:inline]
      render :action => 'inline_new', :layout => false
    end
    
  end
    
  # GET /photos/1;edit
  def edit
    @photo = Photo.find(params[:id])
    @user = @photo.user
  end

  # POST /photos
  # POST /photos.xml
  def create
    @user = current_user

    @photo = Photo.new(params[:photo])
    @photo.user = @user

    respond_to do |format|
      if @photo.save
        @photo.tag_with(params[:tag_list] || '') 
        #start the garbage collector
        GC.start        
        flash[:notice] = 'Photo was successfully created.'
        
        format.html { 
          render :action => 'inline_new', :layout => false and return if params[:inline]
          redirect_to user_photo_url(:id => @photo, :user_id => @photo.user) 
        }
        format.js {
          responds_to_parent do
            render :update do |page|
              page << "upload_image_callback('#{@photo.public_filename()}', '#{@photo.display_name}', '#{@photo.id}');"
            end
          end                
        }
      else
        format.html { 
          render :action => 'inline_new', :layout => false and return if params[:inline]                
          render :action => "new" 
        }
        format.js {
          responds_to_parent do
            render :update do |page|
              page.alert('Sorry, there was an error uploading the photo.')
            end
          end                
        }
      end
    end
  end
  
  def swfupload  
    # swfupload action set in routes.rb
    @photo = Photo.new :uploaded_data => params[:Filedata]
    @photo.user = current_user
    @photo.save!
    
    # This returns the thumbnail url for handlers.js to use to display the thumbnail
    render :text => @photo.public_filename(:thumb)
  rescue 
    render :text => "Error: #{$!}", :status => 500
  end  
  
  # PUT /photos/1
  # PUT /photos/1.xml
  def update
    @photo = Photo.find(params[:id])
    @user = @photo.user
    @photo.tag_with(params[:tag_list] || '') 
    
    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        format.html { redirect_to user_photo_url(@photo.user, @photo) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  # DELETE /photos/1
  # DELETE /photos/1.xml
  def destroy    
    @user = User.find(params[:user_id])
    @photo = Photo.find(params[:id])
    if @user.avatar.eql?(@photo)
      @user.avatar = nil
      @user.save!
    end
    @photo.destroy
     
    respond_to do |format|
      format.html { redirect_to user_photos_url(@photo.user)   }
    end
  end
  
  def slideshow
    @xml_file = formatted_user_photos_url( {:user_id => @user, :format => :xml}.merge(:tag_name => params[:tag_name]) )
    render :action => 'slideshow'
  end
    
  # protected
  # def require_fake_session
  #   raise session[:user].inspect
  #   fake_session = ActionController::Base.session
  #   @user = Marshal.load(Base64.decode64(fake_session.data))[:user]
  #   raise @user.inspect
  # 
  #   begin
  #     fake_session = ActionController::Base.session_store.find_session(params[:_session_id])
  #     @user = Marshal.load(Base64.decode64(fake_session.data))[:user]
  #     return @user
  #   rescue
  #     render :nothing => true, :status => 500 and return false
  #   end    
  # end
  
  
end