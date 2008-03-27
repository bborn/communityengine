class StatisticsController < BaseController
  include Ziya
  before_filter :login_required
  before_filter :admin_required

  def index
    @total_users = User.count(:conditions => ['activated_at IS NOT NULL'])
    @unactivated_users = User.count(:conditions => ['activated_at IS NULL'])
    @yesterday_new_users = find_new_users(1.day.ago.midnight, Time.today.midnight)
    @today_new_users = find_new_users(Time.today.midnight, Time.today.tomorrow.midnight)  
    @active_users_count = Activity.find(:all, :group => "user_id", :conditions => ["created_at > ?", 1.month.ago]).size

    @active_users = User.find_by_activity({:since => 1.month.ago})

    sql = "SELECT AVG(DATE_FORMAT(NOW(), '%Y') - DATE_FORMAT(birthday, '%Y') - (DATE_FORMAT(NOW(), '00-%m-%d') < DATE_FORMAT(birthday, '00-%m-%d'))) as avg_age
      FROM users WHERE birthday IS NOT NULL;"
    @average_age = ActiveRecord::Base.connection.select_all(sql)
    
    @percent_reporting_zip = (User.count(:all, :conditions => "zip IS NOT NULL") / @total_users.to_f)*100
    
    users_reporting_gender = User.count(:all, :conditions => "gender IS NOT NULL")
    @percent_male = (User.count(:all, :conditions => ['gender = ?', User::MALE ]) / users_reporting_gender.to_f) * 100
    @percent_female = (User.count(:all, :conditions => ['gender = ?', User::FEMALE] ) / users_reporting_gender.to_f) * 100        
    
    @featured_writers = User.find_featured

    @posts = Post.find(:all, 
      :conditions => ['? <= posts.created_at AND posts.created_at <= ? AND users.featured_writer = ?', Time.now.beginning_of_month, (Time.now.end_of_month + 1.day), true], :include => :user)        
    @estimated_payment = @posts.sum do |p| 
      p.category.eql?(Category.get(:how_to)) ? 10 : 5
    end

    
  end  

  def activities_chart
    range = (params[:range].blank? ? 10 : params[:range].to_i ) #days
    
    chart = Ziya::Charts::Line.new
    @logins = Activity.count(:group => "date(created_at)", :conditions => ["action = ? AND created_at > ?", 'logged_in', range.days.ago ] )
    @comments = Activity.count(:group => "date(created_at)", :conditions => ["action = ? AND created_at > ?", 'comment', range.days.ago ] )    
    @posts = Activity.count(:group => "date(created_at)", :conditions => ["action = ? AND created_at > ?", 'post', range.days.ago ] )        
    @photos = Activity.count(:group => "date(created_at)", :conditions => ["action = ? AND created_at > ?", 'photo', range.days.ago ] )            
    @clippings = Activity.count(:group => "date(created_at)", :conditions => ["action = ? AND created_at > ?", 'clipping', range.days.ago ] )            

    current = (Time.now.midnight) - ( (range).days + 1.day )
    days = []
    labels = []
    0.upto(range) do |i| 
      current += 1.day
      labels << current.to_s(:line_graph)
      days << current.to_date.to_s(:db)
    end

    chart.add( :axis_category_text, labels )
    
    chart.add( :series, "Logins", days.collect{|d| @logins[d] || 0 } )
    chart.add( :series, "Comments", days.collect{|d| @comments[d] || 0 } )    
    chart.add( :series, "Posts", days.collect{|d| @posts[d] || 0 } )        
    chart.add( :series, "Photos", days.collect{|d| @photos[d] || 0 } )        
    chart.add( :series, "Clippings", days.collect{|d| @clippings[d] || 0 } )            
    render :xml => chart.to_s    
  end
  
    
  protected
  def find_new_users(from, to, limit= nil)
    new_user_cond = Caboose::EZ::Condition.new
    new_user_cond << ["activated_at IS NOT NULL"]
    new_user_cond.created_at >= from
    new_user_cond.created_at <= to    
    return User.find(:all, :conditions => new_user_cond.to_sql, :limit => limit)
  end
  

end
