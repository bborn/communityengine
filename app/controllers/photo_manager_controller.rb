class PhotoManagerController < BaseController
  include Viewable
  before_filter :login_required
  before_filter :find_user
  before_filter :require_current_user
  
  def index
    @albums = current_user.albums.order('id DESC').paginate(:page => params[:page_albums])
    @photos_no_albums = current_user.photos.where('album_id IS NULL').order('id DESC').paginate(:page => params[:page])
  end
end