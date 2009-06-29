require 'pp'

class PhotosController < BaseController
  before_filter :login_required, :only => [:new, :edit, :update, :destroy, :create, :swfupload]
  before_filter :find_user, :only => [:new, :edit, :index, :show, :slideshow, :swfupload]
  before_filter :require_current_user, :only => [:new, :edit, :update, :destroy, :swfupload]

  skip_before_filter :verify_authenticity_token, :only => [:create] #because the TinyMCE image uploader can't provide the auth token

  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:show])

  cache_sweeper :taggable_sweeper, :only => [:create, :update, :destroy]    

  def recent
    @photos = Photo.recent.find(:all, :page => {:current => params[:page]})
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

    @photos = Photo.recent.find(:all, :conditions => cond.to_sql, :include => :tags, :page => {:current => params[:page]})

    @tags = Photo.tag_counts :conditions => { :user_id => @user.id }, :limit => 20

    @rss_title = "#{AppConfig.community_name}: #{@user.login}'s photos"
    @rss_url = user_photos_path(@user,:format => :rss)

    respond_to do |format|
      format.html # index.rhtml
      format.rss {
        render_rss_feed_for(@photos,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'photos', :action => 'index', :user_id => @user) },
             :item => {:title => :name,
                       :description => Proc.new {|photo| description_for_rss(photo)},
                       :link => Proc.new {|photo| user_photo_url(photo.user, photo)},
                       :pub_date => :created_at} })

      }
      format.xml { render :action => 'index.rxml', :layout => false}
    end
  end

  def manage_photos
    if logged_in?
      @user = current_user
      cond = Caboose::EZ::Condition.new
      cond.user_id == @user.id
      if params[:tag_name]
        cond.append ['tags.name = ?', params[:tag_name]]
      end

      @selected = params[:photo_id]
      @photos = Photo.recent.find :all, :conditions => cond.to_sql, :include => :tags, :page => {:size => 10, :current => params[:page]}

    end
    respond_to do |format|
      format.js
    end
  end

  # GET /photos/1
  # GET /photos/1.xml
  def show
    @photo = @user.photos.find(params[:id])
    update_view_count(@photo) if current_user && current_user.id != @photo.user_id
    
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
    @photo.tag_list = params[:tag_list] || ''
    
    @photo.album_id = params[:album_id] || ''    
    @photo.album_id = params[:album_selected] unless params[:album_selected].blank?


    respond_to do |format|
      if @photo.save
        #start the garbage collector
        GC.start
        flash[:notice] = :photo_was_successfully_created.l

        format.html {      
          render :action => 'inline_new', :layout => false and return if params[:inline]
          if params[:album_id]
            redirect_to user_album_path(current_user,params[:album_id])
          else  
            redirect_to user_photo_url(:id => @photo, :user_id => @photo.user)
          end
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
              page.alert(:sorry_there_was_an_error_uploading_the_photo.l)
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
    @photo.album_id =  params[:album_id] if params[:album_id]
    @photo.album_id = params[:album_selected] unless params[:album_selected].blank?
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
    @photo.tag_list = params[:tag_list] || ''
    @photo.album_id = params[:photo][:album_id]

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
    @xml_file = user_photos_url( {:user_id => @user, :format => :xml}.merge(:tag_name => params[:tag_name]) )
    render :action => 'slideshow'
  end

  protected

  def description_for_rss(photo)
    "<a href='#{user_photo_url(photo.user, photo)}' title='#{photo.name}'><img src='#{photo.public_filename(:large)}' alt='#{photo.name}' /><br />#{photo.description}</a>"
  end

end
