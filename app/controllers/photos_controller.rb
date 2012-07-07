require 'pp'

class PhotosController < BaseController
  include Viewable  
  before_filter :login_required, :only => [:new, :edit, :update, :destroy, :create, :swfupload]
  before_filter :find_user, :only => [:new, :edit, :index, :show]
  before_filter :require_current_user, :only => [:new, :edit, :update, :destroy]

  skip_before_filter :verify_authenticity_token, :only => [:create] #because the TinyMCE image uploader can't provide the auth token

  uses_tiny_mce do
    {:only => [:show], :options => configatron.simple_mce_options}
  end

  cache_sweeper :taggable_sweeper, :only => [:create, :update, :destroy]    

  def recent
    @photos = Photo.recent.page(params[:page])
  end
  
  def index
    @user = User.find(params[:user_id])

    @photos = Photo.where(:user_id => @user.id).includes(:tags)
    if params[:tag_name]
      @photos = @photos.where('tags.name = ?', params[:tag_name])
    end
    
    @photos = @photos.recent.page(params[:page]).per(20)
  
    @tags = Photo.includes(:taggings).where(:user_id => @user.id).tag_counts(:limit => 20)
  
    @rss_title = "#{configatron.community_name}: #{@user.login}'s photos"
    @rss_url = user_photos_path(@user,:format => :rss)

    respond_to do |format|
      format.html 
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
      @photos = current_user.photos.recent.includes(:tags)      
      if params[:tag_name]
        @photos = @photos.where('tags.name = ?', params[:tag_name])
      end
      @selected = params[:photo_id]
      @photos = @photos.page(params[:page]).per(10)
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
              page << "upload_image_callback('#{@photo.photo.url()}', '#{@photo.display_name}', '#{@photo.id}');"
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


  protected

  def description_for_rss(photo)
    "<a href='#{user_photo_url(photo.user, photo)}' title='#{photo.name}'><img src='#{photo.photo.url(:large)}' alt='#{photo.name}' /><br />#{photo.description}</a>"
  end

end
