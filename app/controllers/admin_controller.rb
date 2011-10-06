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
  
  def contests
    @contests = Contest.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @contests.to_xml }
    end    
  end

  def events
    @events = Event.find(:all, :order => 'start_time DESC', :page => {:current => params[:page]})
  end
  
  def messages
    @user = current_user
    @messages = Message.find(:all, :page => {:current => params[:page], :size => 50}, :order => 'created_at DESC')
  end
  
  def users
    cond = Caboose::EZ::Condition.new
    if params['login']    
      cond.login =~ "%#{params['login']}%"
    end
    if params['email']
      cond.email =~ "%#{params['email']}%"
    end        
    if params['featured']
      cond.featured_writer == true
    end        
    if params['id']    
      cond.id == params['id']
    end
    
    
    @users = User.recent.find(:all, :page => {:current => params[:page], :size => 100}, :conditions => cond.to_sql)      
    
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
    @comments = @search.find(:all, :page => {:current => params[:page], :size => 100})
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
