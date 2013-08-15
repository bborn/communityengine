class StatisticsController < BaseController
  before_filter :login_required
  before_filter :admin_required

  def index
    @total_users = User.where('activated_at IS NOT NULL').count
    @unactivated_users = User.where('activated_at IS NULL').count

    @yesterday_new_users = find_new_users(1.day.ago.midnight, Date.today.midnight)
    @today_new_users = find_new_users(Date.today.midnight, Date.today.tomorrow.midnight)  

    # Query returns a hash of user_id to number of activities for that user.
    @active_users_count = Activity.group("user_id").having("count(created_at > ?) > 0", 1.month.ago).count.keys.size

    @active_users = User.find_by_activity({:since => 1.month.ago})
    
    @percent_reporting_zip = (User.where("zip IS NOT NULL").count / @total_users.to_f)*100
    
    users_reporting_gender = User.where("gender IS NOT NULL").count
    @percent_male = (User.where('gender = ?', User::MALE).count / users_reporting_gender.to_f) * 100
    @percent_female = (User.where('gender = ?', User::FEMALE).count / users_reporting_gender.to_f) * 100
    
    @featured_writers = User.find_featured

    @posts = Post.includes(:user).where('? <= posts.published_at AND posts.published_at <= ? AND users.featured_writer = ?', Time.now.beginning_of_month, (Time.now.end_of_month + 1.day), true).includes(:users)
  end  

      
  protected
    def find_new_users(from, to, limit= nil)
      User.active.where(:created_at => from..to)
    end
  

end
