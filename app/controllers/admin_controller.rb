class AdminController < BaseController
  before_filter :admin_required
  
  def users
    cond = Caboose::EZ::Condition.new
    if params['login']    
      cond.login =~ "%#{params['login']}%"
    end
    if params['email']
      cond.email =~ "%#{params['email']}%"
    end        
    
    @pages, @users = paginate :users, :per_page => 100, :order => "created_at DESC", :conditions => cond.to_sql
  end
  
  def activate_user
    user = User.find(params[:id])
    user.activate
    flash[:notice] = "The user was activated"
    redirect_to :action => :users
  end
  
end