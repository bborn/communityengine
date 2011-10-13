class AdminController < BaseController
  before_filter :admin_required
  
  def clear_cache
    case Rails.cache
      when ActiveSupport::Cache::FileStore
        dir = Rails.cache.cache_path
        unless dir == Rails.public_path
          FileUtils.rm_r(Dir.glob(dir+"/*")) rescue Errno::ENOENT
          Rails.logger.info("Cache directory fully swept.")
        end
        flash[:notice] = :cache_cleared.l
      else
        Rails.logger.warn("Cache not swept: you must override AdminController#clear_cache to support #{Rails.cache}") 
    end
    redirect_to admin_dashboard_path and return    
  end
  
  def events
    @events = Event.order('start_time DESC').page(params[:page])
  end
  
  def messages
    @user = current_user
    @messages = Message.order('created_at DESC').page(params[:page]).per(50)
  end
  
  def users
    @users = User.recent
    user = User.arel_table

    if params['login']    
      @users = @users.where('`users`.login LIKE ?', "%#{params['login']}%")
    end
    if params['email']
      @users = @users.where('`users`.email LIKE ?', "%#{params['email']}%")
    end        

    @users = @users.page(params[:page]).per(100)
    
    respond_to do |format|
      format.html
      format.xml {
        render :xml => @users.to_xml(:except => [ :password, :crypted_password, :single_access_token, :perishable_token, :password_salt, :persistence_token ])
      }
    end
  end
  
  def comments
    @search = Comment.search(params[:search])
    @search.order ||= :descend_by_created_at        
    @comments = @search.page(params[:page]).per(100)
  end
  
  def activate_user
    user = User.find(params[:id])
    user.activate
    flash[:notice] = :the_user_was_activated.l
    redirect_to :action => :users
  end
  
  def deactivate_user
    user = User.find(params[:id])
    user.deactivate
    flash[:notice] = :the_user_was_deactivated.l
    redirect_to :action => :users
  end  
  
  def subscribers
    @users = User.find(:all, :conditions => ["notify_community_news = ? AND users.activated_at IS NOT NULL", (params[:unsubs] ? false : true)])    
    
    respond_to do |format|
      format.xml {
        render :xml => @users.to_xml(:only => [:login, :email])
      }
    end
    
  end
  
end
