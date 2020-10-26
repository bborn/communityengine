class UsersController < BaseController
  include Viewable
  cache_sweeper :taggable_sweeper, :only => [:activate, :update, :destroy]

  before_action :login_required, :only => [:edit, :edit_account, :update, :welcome_photo, :welcome_about,
                                          :welcome_invite, :return_admin, :assume, :featured,
                                          :toggle_featured, :edit_pro_details, :update_pro_details, :dashboard, :deactivate,
                                          :crop_profile_photo, :upload_profile_photo]
  before_action :find_user, :only => [:edit, :edit_pro_details, :show, :update, :statistics, :deactivate,
                                      :crop_profile_photo, :upload_profile_photo ]
  before_action :require_current_user, :only => [:edit, :update, :update_account,
                                                :edit_pro_details, :update_pro_details,
                                                :welcome_photo, :welcome_about, :welcome_invite, :deactivate,
                                                :crop_profile_photo, :upload_profile_photo]
  before_action :admin_required, :only => [:assume, :destroy, :featured, :toggle_featured, :toggle_moderator]
  before_action :admin_or_current_user_required, :only => [:statistics]

  def activate
    redirect_to signup_path and return if params[:id].blank?
    @user = User.find_by_activation_code(params[:id])
    if @user and @user.activate
      self.current_user = @user
      @user.track_activity(:joined_the_site)
      flash[:notice] = :thanks_for_activating_your_account.l
      redirect_to welcome_photo_user_path(@user) and return
    end

    flash[:error] = :account_activation_error.l_with_args(:email => configatron.support_email)
    redirect_to signup_path
  end

  def deactivate
    @user.deactivate
    current_user_session.destroy if current_user_session
    flash[:notice] = :deactivate_completed.l
    redirect_to login_path
  end

  def index
    @users, @search, @metro_areas, @states = User.search_conditions_with_metros_and_states(params)

    @users = @users.active.recent.includes(:tags).page(params[:page]).per(20)

    @metro_areas, @states = User.find_country_and_state_from_search_params(params)

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
    @accepted_friendships       = @user.accepted_friendships.limit(5).to_a.collect{|f| f.friend }
    @pending_friendships_count  = @user.pending_friendships.count()

    @comments       = @user.comments.limit(10).order('created_at DESC')
    @photo_comments = Comment.find_photo_comments_for(@user)
    @users_comments = Comment.find_comments_by_user(@user).limit(5)

    @recent_posts   = @user.posts.recent.limit(2)
    @clippings      = @user.clippings.limit(5)
    @photos         = @user.photos.limit(5)
    @comment        = Comment.new

    @my_activity = Activity.recent.by_users([@user.id]).limit(10)

    update_view_count(@user) unless current_user && current_user.eql?(@user)
  end

  def new
    @user         = User.new(:birthday => Date.parse((Time.now - 25.years).to_s))
    @inviter_id   = params[:id]
    @inviter_code = params[:code]
  end

  def create
    @user       = User.new(user_params)
    @user.role  = Role[:member]

    if (!configatron.require_captcha_on_signup || verify_recaptcha(@user)) && @user.save
      create_friendship_with_inviter(@user, params)
      flash[:notice] = :email_signup_thanks.l_with_args(:email => @user.email)
      redirect_to signup_completed_user_path(@user)
    else
      render :action => 'new'
    end
  end

  def edit
    @metro_areas, @states = setup_locations_for(@user)
    @avatar     = (@user.avatar || @user.build_avatar)
  end

  def update
    @metro_areas, @states = setup_locations_for(@user)

    unless params[:metro_area_id].blank?
      @user.metro_area  = MetroArea.find(params[:metro_area_id])
      @user.state       = (@user.metro_area && @user.metro_area.state) ? @user.metro_area.state : nil
      @user.country     = @user.metro_area.country if (@user.metro_area && @user.metro_area.country)
    else
      @user.metro_area = @user.state = @user.country = nil
    end

    @user.tag_list = params[:tag_list] || ''

    if user_params
      attributes = user_params.permit!
      attributes[:avatar_attributes][:user_id] = @user.id if attributes[:avatar_attributes]
      if @user.update_attributes(attributes)
        @user.track_activity(:updated_profile)

        flash[:notice] = :your_changes_were_saved.l
        unless params[:welcome]
          redirect_to user_path(@user)
        else
          redirect_to :action => "welcome_#{params[:welcome]}", :id => @user
        end
      else
        render :action => 'edit'
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    unless @user.admin? || @user.featured_writer?
      @user.spam! if params[:spam] && configatron.has_key?(:akismet_key)
      @user.destroy
      flash[:notice] = :the_user_was_deleted.l
    else
      flash[:error] = :you_cant_delete_that_user.l
    end
    respond_to do |format|
      format.html { redirect_to users_url }
      format.js   {
        render :inline => flash[:error], :status => 500 if flash[:error]
        render if flash[:notice]
      }
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

  def crop_profile_photo
    unless @photo = @user.avatar
      flash[:notice] = :no_profile_photo.l
      redirect_to upload_profile_photo_user_path(@user) and return
    end
    return unless request.put? || request.patch?

    @photo.update_attributes(:crop_x => params[:crop_x], :crop_y => params[:crop_y], :crop_w => params[:crop_w], :crop_h => params[:crop_h])
    redirect_to user_path(@user)
  end

  def upload_profile_photo
    @avatar       = Photo.new(avatar_params)
    return unless request.put? || request.patch?

    @avatar.user  = @user
    if @avatar.save
      @user.avatar  = @avatar
      @user.save
      redirect_to crop_profile_photo_user_path(@user)
    end
  end

  def edit_account
    @user             = current_user
    @authorizations   = current_user.authorizations
    @is_current_user  = true
  end

  def update_account
    @user             = current_user

    if @user.update_attributes(user_params)
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

    if @user.update_attributes(user_params)
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

        @friendship.save!
        reverse_friendship.save!
      end
    end
  end

  def signup_completed
    @user = User.find(params[:id])
    redirect_to home_path and return unless @user
  end

  def welcome_photo
    @user = User.find(params[:id])
    @avatar = (@user.avatar || @user.build_avatar)
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
    flash[:notice] = :walkthrough_complete.l_with_args(:site => configatron.community_name)
    redirect_to user_path
  end

  def forgot_username
    return unless request.post?

    if @user = User.active.find_by_email(params[:email])
      UserNotifier.forgot_username(@user).deliver_now
      redirect_to login_url
      flash[:info] = :your_username_was_emailed_to_you.l
    else
      flash[:error] = :sorry_we_dont_recognize_that_email_address.l
    end
  end

  def resend_activation

    if params[:email]
      @user = User.find_by_email(params[:email])
    else
      @user = User.find(params[:id])
    end

    if @user && !@user.active?
      flash[:notice] = :activation_email_resent_message.l
      UserNotifier.signup_notification(@user).deliver_now
      redirect_to login_path and return
    else
      flash[:notice] = :activation_email_not_sent_message.l
    end
  end

  def assume
    user = User.find(params[:id])

    if assumed_user_session = self.assume_user(user)
      redirect_to user_path(assumed_user_session.record)
    else
      redirect_to users_path
    end
  end

  def return_admin
    return_to_admin
  end

  def metro_area_update

    country = Country.find(params[:country_id]) unless params[:country_id].blank?
    state   = State.find(params[:state_id]) unless params[:state_id].blank?
    states  = country ? country.states : []

    if states.any?
      metro_areas = state ? state.metro_areas.order("name ASC") : []
    else
      metro_areas = country ? country.metro_areas.order("name ASC") : []
    end

    respond_to do |format|
      format.js {
        render :partial => 'shared/location_chooser', :locals => {
          :states => states,
          :metro_areas => metro_areas,
          :selected_country => params[:country_id].to_i,
          :selected_state => params[:state_id].to_i,
          :selected_metro_area => nil,
          :js => true }
      }
    end
  end

  def toggle_featured
    @user = User.find(params[:id])
    @user.toggle!(:featured_writer)
    redirect_to user_path(@user)
  end

  def toggle_moderator
    @user = User.find(params[:id])
    if not @user.admin?
      @user.role = @user.moderator? ? Role[:member] : Role[:moderator]
      @user.save!
    else
      flash[:error] = :you_cannot_make_an_administrator_a_moderator.l
    end
    redirect_to user_path(@user)
  end

  def statistics
    if params[:date]
      date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i)
      @month = Time.parse(date.to_s)
    else
      @month = Date.today
    end

    start_date  = @month.beginning_of_month
    end_date    = @month.end_of_month.end_of_day

    @posts = @user.posts.where('? <= published_at AND published_at <= ?', start_date, end_date)

    @estimated_payment = @posts.to_a.sum do |p|
      7
    end

    respond_to do |format|
      format.html
      format.xml {
        render :xml => @posts.to_xml(:include => :category)
      }
    end
  end

  def delete_selected
    if params[:delete]
      params[:delete].each { |id|
        user = User.find(id)
        unless user.admin? || user.featured_writer?
          user.spam! if params[:spam] && configatron.has_key?(:akismet_key)
          user.destroy
        end
      }
    end
    flash[:notice] = :the_selected_users_were_deleted.l
    redirect_to admin_users_path
  end

  protected
    def setup_metro_areas_for_cloud
      @metro_areas_for_cloud = MetroArea.where("users_count > 0", :order => "users_count DESC").limit(100)
      @metro_areas_for_cloud = @metro_areas_for_cloud.sort_by{|m| m.name}
    end

    def setup_locations_for(user)
      metro_areas = states = []

      states = user.country.states if user.country

      metro_areas = user.state.metro_areas.order("name") if user.state

      return metro_areas, states
    end

    def admin_or_current_user_required
      current_user && (current_user.admin? || @is_current_user) ? true : access_denied
    end


  def avatar_params
    params[:avatar] && params[:avatar].permit(:name, :description, :album_id, :photo)
  end

  def user_params
    params[:user].permit(:avatar_id, :company_name, :country_id, :description, :email,
                                 :firstname, :fullname, :name, :gender, :lastname, :login, :metro_area_id,
                                 :middlename, :notify_comments, :notify_community_news,
                                 :notify_friend_requests, :password, :password_confirmation,
                                 :profile_public, :state_id, :stylesheet, :time_zone, :vendor, :zip,
                                 :tag_list,
                                 {:avatar_attributes => [:id, :name, :description, :album_id, :user, :user_id, :photo, :photo_remote_url]}, :birthday) if params[:user]
  end

  def comment_params
    params[:comment].permit(:author_name, :author_email, :notify_by_email, :author_url, :comment)
  end
end
