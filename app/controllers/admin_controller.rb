class AdminController < BaseController
  before_filter :admin_required
  
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
    
    @users = User.recent.find(:all, :page => {:current => params[:page], :size => 100}, :conditions => cond.to_sql)      
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
  
end
