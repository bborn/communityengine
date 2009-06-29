class AlbumsController < BaseController
  include Viewable
  before_filter :login_required, :except => [:show]
  before_filter :find_user, :only => [:new, :edit, :index]
  before_filter :require_current_user, :only => [:new, :edit, :update, :destroy]
  # GET /albums/1
  # GET /albums/1.xml
  def show
    @album = Album.find(params[:id])
    update_view_count(@album) if current_user && current_user.id != @album.user_id
    @album_photos = Photo.find(:all, :page => { :start => 1, :current => params[:page], :size => 8 },
     :conditions => ['album_id = ? AND parent_id IS NULL', params[:id]])
   
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @album }
    end
  end
  


  # GET /albums/new
  # GET /albums/new.xml
  def new
    @album = Album.new(params[:album])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @album }
    end
  end

  # GET /albums/1/edit
  def edit
    @album = Album.find(params[:id])
  end

  # POST /albums
  # POST /albums.xml
  def create
    @album = Album.new(params[:album])
    @album.user_id = current_user.id
    
    respond_to do |format|
      if @album.save
        if params[:go_to] == 'only_create'
          flash[:notice] = :album_was_successfully_created.l 
          format.html { redirect_to(user_photo_manager_index_path(current_user)) }       
        else
          format.html { redirect_to(new_user_album_photo_path(current_user,@album)) }
        end
      else
        format.html { render :action => 'new' }
      end 
    end
  end

  # PUT /albums/1
  # PUT /albums/1.xml
  def update
    @album = Album.find(params[:id])

    respond_to do |format|
      if @album.update_attributes(params[:album])
        flash[:notice] = :album_updated.l
        format.html { redirect_to(user_album_path(current_user, @album)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @album.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /albums/1
  # DELETE /albums/1.xml
  def destroy  
    @album = Album.find(params[:id])
    @album.destroy

    respond_to do |format|
      format.html { redirect_to user_photo_manager_index_path(current_user) }
      format.xml  { head :ok }
    end
  end
  
  def add_photos
    @album = Album.find(params[:id])
    #@photos_no_albums = current_user.photos_no_albums
    #@user_albums = Album.find(:all, :conditions => ['id != ?', params[:id]])
  end
  
  def photos_added
    @album = Album.find(params[:id])
    @album.photo_ids = params[:album][:photos_ids].uniq
    redirect_to user_albums_path(current_user)
    flash[:notice] = :album_added_photos.l
  end
  
  def paginate_photos
   @album = Album.find(params[:id])
   @page = params[:next_page]
   album_type = params[:album_type]
   case album_type
    when 'no_album'
      @photos = current_user.photos_no_albums(@page)
      @next_page = @photos.next_page
   end
  end
end
