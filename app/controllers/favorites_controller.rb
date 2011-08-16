class FavoritesController < BaseController
  before_filter :login_required, :only => [:destroy]
  before_filter :find_user, :only => [:show, :index]

  cache_sweeper :favorite_sweeper, :only => [:create, :destroy]  
  
  def create
    @favoritable = params[:favoritable_type].classify.constantize.find(params[:favoritable_id])
    @favorite = Favorite.new(:ip_address => request.remote_ip, :favoritable => @favoritable )
    @favorite.user = current_user || nil
    @favorite.save
    
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    @favorite = current_user.favorites.find(params[:id])
    @favorite.destroy
    
    respond_to do |format|
      format.js
    end    
  end
  
  def show
    @favorite = @user.favorites.find(params[:id])
  end
  
  def index  
    @favorites = Favorite.recent.by_user(@user).page(params[:page])
  end
  
  
end