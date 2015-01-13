class PhotoManagerController < BaseController
  include Viewable
  before_action :login_required
  before_action :find_user
  before_action :require_current_user
  
  def index
    @albums = current_user.albums.order('id DESC').page(params[:page_albums])
    @photos_no_albums = current_user.photos.where('album_id IS NULL').order('id DESC').page(params[:page])
  end
end