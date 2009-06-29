class PhotoManagerController < BaseController
  include Viewable
  before_filter :login_required
  before_filter :find_user
  before_filter :require_current_user
  
  def index
    @albums = Album.find(:all, :conditions => ['user_id = ?', current_user], :order => 'id DESC')
    @photos_no_albums = Photo.find(:all, :page => { :start => 1, :current => params[:page], :size => 9 },
     :conditions => ['album_id IS NULL AND parent_id IS NULL AND user_id = ?', current_user],
     :order => 'id DESC')
  end
end