class UsersController < BaseController
  if AppConfig.closed_beta_mode
    skip_before_filter :beta_login_required, :only => [:new, :create, :activate]
    before_filter :require_invitation, :only => [:new, :create]
    
    def require_invitation
      redirect_to home_path and return false unless params[:inviter_id] && params[:inviter_code]
      redirect_to home_path and return false unless User.find(params[:inviter_id]).valid_invite_code?(params[:inviter_code])
    end
  end    

  include Viewable
  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}), 
    :only => [:new, :create, :update, :edit, :welcome_about])
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:show])

    
  before_filter :login_required, :only => [:edit, :edit_account, :update, :welcome_photo, :welcome_about, 
                                          :welcome_invite, :return_admin, :assume, :featured, 
                                          :toggle_featured, :edit_pro_details, :update_pro_details, :dashboard]
  before_filter :find_user, :only => [:edit, :edit_pro_details, :show, :update, :destroy, :statistics ]
  before_filter :require_current_user, :only => [:edit, :update, :update_account,
                                                :edit_pro_details, :update_pro_details,
                                                :welcome_photo, :welcome_about, :welcome_invite]
  before_filter :admin_required, :only => [:assume, :destroy, :featured, :toggle_featured]
  before_filter :admin_or_current_user_required, :only => [:statistics]  

  def activate
    @user = User.find_by_activation_code(params[:id])
    if @user and @user.activate
      self.current_user = @user
      redirect_to welcome_photo_user_path(@user)
      flash[:notice] = "Thanks for activating your account!" 
      return
    end
    flash[:error] = "Account activation failed. Your account may already be active. Try logging in or e-mail #{AppConfig.support_email} for help."
    redirect_to signup_path     
  end

  def index
    cond, @search, @metro_areas, @states = User.paginated_users_conditions_with_search(params)    
    @pages, @users = paginate :users, :order => "created_at DESC", :conditions => cond.to_sql, :include => :tags
    @tags = User.tags_count :limit => 10
    
    setup_metro_areas_for_cloud
  end
  
  def dashboard
    @user = current_user
    @network_activity = @user.network_activity
    @recommended_posts = @user.recommended_posts
  end
  
  def show  
    @friend_count = @user.accepted_friendships.count
    @accepted_friendships = @user.accepted_friendships.find(:all, :limit => 5).collect{|f| f.friend }
    @pending_friendships_count = @user.pending_friendships.count()

    @comments = @user.comments.find(:all, :limit => 10, :order => 'created_at DESC')
    @photo_comments = Comment.find_photo_comments_for(@user)
    
    @users_comments = Comment.find_comments_by_user(@user, :limit => 5)

    @recent_posts = @user.posts.find(:all, :limit => 2, :order => "created_at DESC")
    @clippings = @user.clippings.find(:all, :limit => 5)
    @photos = @user.photos.find(:all, :limit => 4)
    @comment = Comment.new(params[:comment])
    update_view_count(@user) unless current_user && current_user.eql?(@user)
  end
  
  # render new.rhtml
  def new
    @user = User.new( {:birthday => Date.parse((Time.now - 25.years).to_s) }.merge(params[:user] || {}) )
    @inviter_id = params[:id]
    @inviter_code = params[:code]
    render :action => 'new', :layout => 'beta' and return if AppConfig.closed_beta_mode    
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    create_friendship_with_inviter(@user, params)
    flash[:notice] = "Thanks for signing up! You should receive an e-mail confirmation shortly at #{@user.email}"
    redirect_to signup_completed_user_path(@user)
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
    
  def edit 
    @metro_areas, @states = setup_locations_for(@user)
    @skills = Skill.find(:all)
    @offering = Offering.new

    @avatar = Photo.new
  end
  
  def update
    @user.attributes = params[:user]
    @metro_areas, @states = setup_locations_for(@user)

    unless params[:metro_area_id].blank?
      @user.metro_area = MetroArea.find(params[:metro_area_id])
      @user.state = (@user.metro_area && @user.metro_area.state) ? @user.metro_area.state : nil
      @user.country = @user.metro_area.country if (@user.metro_area && @user.metro_area.country)
    else
      @user.metro_area = nil
      @user.state = nil
      @user.country = nil
    end
  
    @avatar = Photo.new(params[:avatar])
    @avatar.user = @user
    if @avatar.save
      @user.avatar = @avatar
    end
    
    if @user.save!
      @user.track_activity(:updated_profile)
      
      @user.tag_with(params[:tag_list] || '')     
      flash[:notice] = "Your changes were saved."
      unless params[:welcome] 
        redirect_to user_path(@user)
      else
        redirect_to :action => "welcome_#{params[:welcome]}", :id => @user
      end
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
  def destroy
    unless @user.admin?
      @user.destroy
      flash[:notice] = "The user was deleted."
    else
      flash[:error] = "You can't delete that user."
    end
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end
  
  def change_profile_photo
    @user = User.find(params[:id])
    @photo = Photo.find(params[:photo_id])
    @user.avatar = @photo
    if @user.save!
      flash[:notice] = "Your changes were saved."
      redirect_to user_photo_path(@user, @photo)
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
    
  def edit_account
    # allow account editing from a path like /account/edit
    # this lets us give people a link in mass e-mails without having to lookup each user's unique path
    @user = current_user
    @is_current_user = true
  end
  
  def update_account
    @user = current_user
    @user.attributes = params[:user]

    if @user.save!
      flash[:notice] = "Your changes were saved."
      redirect_to user_path(@user)
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit_account'
  end

  def edit_pro_details
    @user = User.find(params[:id])
  end

  def update_pro_details
    @user = User.find(params[:id])
    @user.add_offerings(params[:offerings]) if params[:offerings]
    
    @user.attributes = params[:user]

    if @user.save!
      respond_to do |format|
        format.html { 
          flash[:notice] = "Your changes were saved."
          redirect_to edit_pro_details_user_path(@user)   
        }
        format.js {
          render :text => 'success'
        }
      end

    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit_pro_details'
  end
    
  def create_friendship_with_inviter(user, options = {})
    unless options[:inviter_code].blank? or options[:inviter_id].blank?
      friend = User.find(options[:inviter_id])
      if friend && friend.valid_invite_code?(options[:inviter_code])
        accepted = FriendshipStatus[:accepted]
        @friendship = Friendship.new(:user_id => friend.id, :friend_id => user.id,:friendship_status => accepted, :initiator => true)
        reverse_friendship = Friendship.new(:user_id => user.id, :friend_id => friend.id, :friendship_status => accepted )
        @friendship.save
        reverse_friendship.save
      end
    end
  end
  
  def signup_completed
    @user = User.find(params[:id])
    render :action => 'signup_completed', :layout => 'beta' if AppConfig.closed_beta_mode    
  end
  
  def welcome_photo
    @user = User.find(params[:id])
  end

  def welcome_about
    @user = User.find(params[:id])
    @metro_areas, @states = setup_locations_for(@user)
  end
    
  def welcome_invite
    @user = User.find(params[:id])    
  end
  
  def invite
    @user = User.find(params[:id])    
  end
  
  def welcome_complete
    flash[:notice] = "You've completed the #{AppConfig.community_name} walk-through. Now you can continue exploring!"
    redirect_to user_path
  end
  
  def forgot_password  
    @user = User.find_by_email(params[:email])  
    return unless request.post?   
    if @user
      if @user.reset_password
        UserNotifier.deliver_reset_password(@user)
        @user.save
        redirect_to login_url
        flash[:info] = "Your password has been reset and emailed to you."
      end
    else
      flash[:error] = "Sorry. We don't recognize that email address."
    end 
  end

  def forgot_username  
    @user = User.find_by_email(params[:email])  
    return unless request.post?   
    if @user
      if @user.reset_password
        UserNotifier.deliver_forgot_username(@user)
        @user.save
        redirect_to login_url
        flash[:info] = "Your username was emailed to you."
      end
    else
      flash[:error] = "Sorry. We don't recognize that email address."
    end 
  end

  
  def assume
    user = User.find(params[:id])
    self.current_user = user
    redirect_to user_path(current_user)
  end

  def return_admin
    unless session[:admin_id].nil? or current_user.admin?
      admin = User.find(session[:admin_id])
      if admin.admin?
        self.current_user = admin
        redirect_to user_path(admin)
      end
    else
      redirect_to login_path
    end
  end

  def metro_area_update
    return unless request.xhr?
    if params[:state_id]
      metro_areas = MetroArea.find_all_by_state_id(params[:state_id], :order => "name")
      render :partial => 'shared/location_chooser', :locals => {:states => State.find(:all), :metro_areas => metro_areas, :selected_country => Country.get(:us).id, :selected_state => params[:state_id].to_i, :selected_metro_area => nil }
    else
      if params[:country_id].to_i.eql?(Country.get(:us).id)
        render :partial => 'shared/location_chooser', :locals => {:states => State.find(:all), :metro_areas => [], :selected_country => params[:country_id].to_i, :selected_state => params[:state_id].to_i, :selected_metro_area => nil }
      else
        metro_areas = MetroArea.find_all_by_country_id(params[:country_id], :order => "name")
        render :partial => 'shared/location_chooser', :locals => {:states => [], :metro_areas => metro_areas, :selected_country => params[:country_id].to_i, :selected_state => nil, :selected_metro_area => nil }
      end
    end      
  end
  
  def toggle_featured
    @user = User.find(params[:id])
    @user.toggle!(:featured_writer)
    redirect_to user_path(@user)
  end
  
  def statistics
    if params[:date]
      date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i)
      @month = Time.parse(date.to_s)
    else
      @month = Time.today    
    end
    @posts = @user.posts.find(:all, 
      :conditions => ['? <= created_at AND created_at <= ?', @month.beginning_of_month, (@month.end_of_month + 1.day)])    
    
    @estimated_payment = @posts.sum do |p| 
      p.category.eql?(Category.get(:how_to)) ? 10 : 5
    end
  end  
  

  protected
  
  def setup_metro_areas_for_cloud
    @metro_areas_for_cloud = MetroArea.find(:all, :conditions => "users_count > 0", :order => "users_count DESC", :limit => 100)
    @metro_areas_for_cloud = @metro_areas_for_cloud.sort_by{|m| m.name}
  end  
  
  def setup_locations_for(user)
    metro_areas = []
    if user.state
      metro_areas = @user.state.metro_areas
    elsif user.country
      metro_areas = user.country.metro_areas
    end
    states = user.country.eql?(Country.get(:us)) ? State.find(:all) : []    
    return metro_areas, states
  end

  def admin_or_current_user_required
    current_user && (current_user.admin? || @is_current_user) ? true : access_denied     
  end

end
