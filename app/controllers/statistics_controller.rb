class StatisticsController < BaseController
  before_filter :login_required
  before_filter :admin_required

  def index
    @total_users = User.count(:conditions => ['activated_at IS NOT NULL'])
    @unactivated_users = User.count(:conditions => ['activated_at IS NULL'])

    @yesterday_new_users = find_new_users(1.day.ago.midnight, Date.today.midnight)
    @today_new_users = find_new_users(Date.today.midnight, Date.today.tomorrow.midnight)  

    @active_users_count = Activity.count(:all, :group => "user_id", :conditions => ["created_at > ?", 1.month.ago]).size

    @active_users = User.find_by_activity({:since => 1.month.ago})
    
    @percent_reporting_zip = (User.count(:all, :conditions => "zip IS NOT NULL") / @total_users.to_f)*100
    
    users_reporting_gender = User.count(:all, :conditions => "gender IS NOT NULL")
    @percent_male = (User.count(:all, :conditions => ['gender = ?', User::MALE ]) / users_reporting_gender.to_f) * 100
    @percent_female = (User.count(:all, :conditions => ['gender = ?', User::FEMALE] ) / users_reporting_gender.to_f) * 100        
    
    @featured_writers = User.find_featured

    @posts = Post.find(:all, :conditions => ['? <= posts.published_at AND posts.published_at <= ? AND users.featured_writer = ?', Time.now.beginning_of_month, (Time.now.end_of_month + 1.day), true], :include => :user)        
  end  

      
  protected
    def find_new_users(from, to, limit= nil)
      User.active.where(:created_at => from..to)
    end
  

end
