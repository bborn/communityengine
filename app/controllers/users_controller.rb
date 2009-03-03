class UsersController < BaseController
  include Viewable
  cache_sweeper :taggable_sweeper, :only => [:activate, :update, :destroy]  
  
  if AppConfig.closed_beta_mode
    skip_before_filter :beta_login_required, :only => [:new, :create, :activate]
    before_filter :require_invitation, :only => [:new, :create]
    
    def require_invitation
      redirect_to home_path and return false unless params[:inviter_id] && params[:inviter_code]
      redirect_to home_path and return false unless User.find(params[:inviter_id]).valid_invite_code?(params[:inviter_code])
    end
  end    

  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}), 
    :only => [:new, :create, :update, :edit, :welcome_about])
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:show])

  # Filters
  before_filter :login_required, :only => [:edit, :edit_account, :update, :welcome_photo, :welcome_about, 
                                          :welcome_invite, :return_admin, :assume, :featured,
                                          :toggle_featured, :edit_pro_details, :update_pro_details, :dashboard, :deactivate]
  before_filter :find_user, :only => [:edit, :edit_pro_details, :show, :update, :destroy, :statistics, :deactivate ]
  before_filter :require_current_user, :only => [:edit, :update, :update_account,
                                                :edit_pro_details, :update_pro_details,
                                                :welcome_photo, :welcome_about, :welcome_invite, :deactivate]
  before_filter :admin_required, :only => [:assume, :destroy, :featured, :toggle_featured, :toggle_moderator]
  before_filter :admin_or_current_user_required, :only => [:statistics]  

  def activate
    redirect_to signup_path and return if params[:id].blank?
    @user = User.find_by_activation_code(params[:id]) 
    if @user and @user.activate
      self.current_user = @user
      redirect_to welcome_photo_user_path(@user)
      flash[:notice] = :thanks_for_activating_your_account.l 
      return
    end
    flash[:error] = :account_activation_error.l_with_args(:email => AppConfig.support_email) 
    redirect_to signup_path     
  end
  
  def deactivate
    @user.deactivate
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = :deactivate_completed.l
    redirect_to login_path
  end

  def index
    cond, @search, @metro_areas, @states = User.paginated_users_conditions_with_search(params)    
    
    @users = User.recent.find(:all,
      :conditions => cond.to_sql, 
      :include => [:tags], 
      :page => {:current => params[:page], :size => 20}
      )
    
    @tags = User.tag_counts :limit => 10
    
    setup_metro_areas_for_cloud
  end
  
  def dashboard
    @user = current_user
    @network_activity = @user.network_activity
    @recommended_posts = @user.recommended_posts
  end
  
  def show  
    @friend_count               = @user.accepted_friendships.count
    @accepted_friendships       = @user.accepted_friendships.find(:all, :limit => 5).collect{|f| f.friend }
    @pending_friendships_count  = @user.pending_friendships.count()

    @comments       = @user.comments.find(:all, :limit => 10, :order => 'created_at DESC')
    @photo_comments = Comment.find_photo_comments_for(@user)    
    @users_comments = Comment.find_comments_by_user(@user, :limit => 5)

    @recent_posts   = @user.posts.find(:all, :limit => 2, :order => "published_at DESC")
    @clippings      = @user.clippings.find(:all, :limit => 5)
    @photos         = @user.photos.find(:all, :limit => 5)
    @comment        = Comment.new(params[:comment])

    update_view_count(@user) unless current_user && current_user.eql?(@user)
  end
  
  def new
    @user         = User.new( {:birthday => Date.parse((Time.now - 25.years).to_s) }.merge(params[:user] || {}) )
    @inviter_id   = params[:id]
    @inviter_code = params[:code]

    render :action => 'new', :layout => 'beta' and return if AppConfig.closed_beta_mode    
  end

  def create
    @user       = User.new(params[:user])
    @user.role  = Role[:member]

    if (!AppConfig.require_captcha_on_signup || verify_recaptcha(@user)) && @user.save
      create_friendship_with_inviter(@user, params)
      flash[:notice] = :email_signup_thanks.l_with_args(:email => @user.email) 
      redirect_to signup_completed_user_path(@user.activation_code)
    else
      render :action => 'new'
    end
  end
    
  def edit 
    @metro_areas, @states = setup_locations_for(@user)
    @skills               = Skill.find(:all)
    @offering             = Offering.new
    @avatar               = Photo.new
  end
  
  def update
    @user.attributes      = params[:user]
    @metro_areas, @states = setup_locations_for(@user)

    unless params[:metro_area_id].blank?
      @user.metro_area  = MetroArea.find(params[:metro_area_id])
      @user.state       = (@user.metro_area && @user.metro_area.state) ? @user.metro_area.state : nil
      @user.country     = @user.metro_area.country if (@user.metro_area && @user.metro_area.country)
    else
      @user.metro_area = @user.state = @user.country = nil
    end
  
    @avatar       = Photo.new(params[:avatar])
    @avatar.user  = @user

    @user.avatar  = @avatar if @avatar.save
    
    @user.tag_list = params[:tag_list] || ''

    if @user.save!
      @user.track_activity(:updated_profile)
      
      flash[:notice] = :your_changes_were_saved.l
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
    unless @user.admin? || @user.featured_writer?
      @user.destroy
      flash[:notice] = :the_user_was_deleted.l
    else
      flash[:error] = :you_cant_delete_that_user.l
    end
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end
  
  def change_profile_photo
    @user   = User.find(params[:id])
    @photo  = Photo.find(params[:photo_id])
    @user.avatar = @photo

    if @user.save!
      flash[:notice] = :your_changes_were_saved.l
      redirect_to user_photo_path(@user, @photo)
    end
  rescue ActiveRecord::RecordInvalid
    @metro_areas, @states = setup_locations_for(@user)
    render :action => 'edit'
  end
    
  def edit_account
    @user             = current_user
    @is_current_user  = true
  end
  
  def update_account
    @user             = current_user
    @user.attributes  = params[:user]

    if @user.save
      flash[:notice] = :your_changes_were_saved.l
      respond_to do |format|
        format.html {redirect_to user_path(@user)}
        format.js
      end      
    else
      respond_to do |format|
        format.html {render :action => 'edit_account'}
        format.js
      end
    end
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
          flash[:notice] = :your_changes_were_saved.l
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
        accepted    = FriendshipStatus[:accepted]
        @friendship = Friendship.new(:user_id => friend.id, 
          :friend_id => user.id,
          :friendship_status => accepted, 
          :initiator => true)

        reverse_friendship = Friendship.new(:user_id => user.id, 
          :friend_id => friend.id, 
          :friendship_status => accepted )
          
        @friendship.save
        reverse_friendship.save
      end
    end
  end
  
  def signup_completed
    @user = User.find_by_activation_code(params[:id])
    redirect_to home_path and return unless @user
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
    flash[:notice] = :walkthrough_complete.l_with_args(:site => AppConfig.community_name) 
    redirect_to user_path
  end
  
  def forgot_password  
    return unless request.post?   

    @user = User.find_by_email(params[:email])  
    if @user && @user.reset_password
      UserNotifier.deliver_reset_password(@user)
      @user.save
      redirect_to login_url
      flash[:info] = :your_password_has_been_reset_and_emailed_to_you.l      
    else
      flash[:error] = :sorry_we_dont_recognize_that_email_address.l
    end 
  end

  def forgot_username  
    return unless request.post?   
    
    if @user = User.find_by_email(params[:email])
      UserNotifier.deliver_forgot_username(@user)
      redirect_to login_url
      flash[:info] = :your_username_was_emailed_to_you.l      
    else
      flash[:error] = :sorry_we_dont_recognize_that_email_address.l
    end 
  end

  def resend_activation
    return unless request.post?       

    @user = User.find_by_email(params[:email])    
    if @user && !@user.active?
      flash[:notice] = :activation_email_resent_message.l :admin_email => AppConfig.support_email
      UserNotifier.deliver_signup_notification(@user)    
      redirect_to login_path and return
    else
      flash[:notice] = :activation_email_not_sent_message.l
    end
  end
  
  def assume
    self.current_user = User.find(params[:id])
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
    
    country = Country.find(params[:country_id]) unless params[:country_id].blank?
    state   = State.find(params[:state_id]) unless params[:state_id].blank?
    states  = country ? country.states.sort_by{|s| s.name} : []
    
    if states.any?
      metro_areas = state ? state.metro_areas.all(:order => "name") : []
    else
      metro_areas = country ? country.metro_areas : []
    end

    render :partial => 'shared/location_chooser', :locals => {
      :states => states, 
      :metro_areas => metro_areas, 
      :selected_country => params[:country_id].to_i, 
      :selected_state => params[:state_id].to_i, 
      :selected_metro_area => nil }
  end
  
  def toggle_featured
    @user = User.find(params[:id])
    @user.toggle!(:featured_writer)
    redirect_to user_path(@user)
  end

  def toggle_moderator
    @user = User.find(params[:id])
    @user.role = @user.moderator? ? Role[:member] : Role[:moderator]
    @user.save!
    redirect_to user_path(@user)
  end

  def statistics
    if params[:date]
      date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i)
      @month = Time.parse(date.to_s)
    else
      @month = Time.today    
    end
    
    start_date  = @month.beginning_of_month
    end_date    = @month.end_of_month + 1.day
    
    @posts = @user.posts.find(:all, 
      :conditions => ['? <= published_at AND published_at <= ?', start_date, end_date])    
    
    @estimated_payment = @posts.sum do |p| 
      7
    end
  end  
  

  protected  
    def setup_metro_areas_for_cloud
      @metro_areas_for_cloud = MetroArea.find(:all, :conditions => "users_count > 0", :order => "users_count DESC", :limit => 100)
      @metro_areas_for_cloud = @metro_areas_for_cloud.sort_by{|m| m.name}
    end  
  
    def setup_locations_for(user)
      metro_areas = states = []
          
      states = user.country.states if user.country
      
      metro_areas = user.state.metro_areas.all(:order => "name") if user.state
    
      return metro_areas, states
    end

    def admin_or_current_user_required
      current_user && (current_user.admin? || @is_current_user) ? true : access_denied     
    end

end
