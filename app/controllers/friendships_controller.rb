class FriendshipsController < BaseController
  before_filter :login_required, :except => [:accepted, :index]
  before_filter :find_user, :only => [:accepted, :pending, :denied]
  before_filter :require_current_user, :only => [:accept, :deny, :pending, :destroy]

  def index
    @body_class = 'friendships-browser'
    
    @user = (params[:id] ||params[:user_id]) ? User.find((params[:id] || params[:user_id] )): Friendship.find(:first, :order => "rand()").user
    @friendships = Friendship.find(:all, :conditions => ['user_id = ? OR friend_id = ?', @user.id, @user.id], :limit => 40, :order => "rand()")
    @users = User.find(:all, :conditions => ['users.id in (?)', @friendships.collect{|f| f.friend_id }])    
    
    respond_to do |format|
      format.html 
      format.xml { render :action => 'index.rxml', :layout => false}    
    end
  end
  
  def deny
    @user = User.find(params[:user_id])    
    @friendship = @user.friendships.find(params[:id])
 
    respond_to do |format|
      if @friendship.update_attributes(:friendship_status => FriendshipStatus[:denied]) && @friendship.reverse.update_attributes(:friendship_status => FriendshipStatus[:denied])
        flash[:notice] = :the_friendship_was_denied.l
        format.html { redirect_to denied_user_friendships_path(@user) }
      else
        format.html { render :action => "edit" }
      end
    end    
  end

  def accept
    @user = User.find(params[:user_id])    
    @friendship = @user.friendships_not_initiated_by_me.find(params[:id])
 
    respond_to do |format|
      if @friendship.update_attributes(:friendship_status => FriendshipStatus[:accepted]) && @friendship.reverse.update_attributes(:friendship_status => FriendshipStatus[:accepted])
        flash[:notice] = :the_friendship_was_accepted.l
        format.html { 
          redirect_to accepted_user_friendships_path(@user) 
        }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def denied
    @user = User.find(params[:user_id])    
    @friendships = @user.friendships.find(:all, :conditions => ["friendship_status_id = ?", FriendshipStatus[:denied].id], :page => {:current => params[:page]})
    
    respond_to do |format|
      format.html
    end
  end


  def accepted
    @user = User.find(params[:user_id])    
    @friend_count = @user.accepted_friendships.count
    @pending_friendships_count = @user.pending_friendships.count
          
    @friendships = @user.friendships.accepted.find :all, :page => {:size => 12, :current => params[:page], :count => @friend_count}
    
    respond_to do |format|
      format.html
    end
  end
  
  def pending
    @user = User.find(params[:user_id])    
    @friendships = @user.friendships.find(:all, :conditions => ["initiator = ? AND friendship_status_id = ?", false, FriendshipStatus[:pending].id])
    
    respond_to do |format|
      format.html
    end
  end
  
  def show
    @friendship = Friendship.find(params[:id])
    @user = @friendship.user
    
    respond_to do |format|
      format.html
    end
  end
  

  def create
    @user = User.find(params[:user_id])
    @friendship = Friendship.new(:user_id => params[:user_id], :friend_id => params[:friend_id], :initiator => true )
    @friendship.friendship_status_id = FriendshipStatus[:pending].id    
    reverse_friendship = Friendship.new(params[:friendship])
    reverse_friendship.friendship_status_id = FriendshipStatus[:pending].id 
    reverse_friendship.user_id, reverse_friendship.friend_id = @friendship.friend_id, @friendship.user_id
    
    respond_to do |format|
      if @friendship.save && reverse_friendship.save
        UserNotifier.friendship_request(@friendship).deliver if @friendship.friend.notify_friend_requests?
        format.html {
          flash[:notice] = :friendship_requested.l_with_args(:friend => @friendship.friend.login) 
          redirect_to accepted_user_friendships_path(@user)
        }
        format.js { render( :inline => :requested_friendship_with.l+" #{@friendship.friend.login}." ) }        
      else
        flash.now[:error] = :friendship_could_not_be_created.l
        format.html { redirect_to user_friendships_path(@user) }
        format.js { render( :inline => "Friendship request failed." ) }                
      end
    end
  end
    
  def destroy
    @user = User.find(params[:user_id])    
    @friendship = Friendship.find(params[:id])
    Friendship.transaction do 
      @friendship.destroy
      @friendship.reverse.destroy
    end
    respond_to do |format|
      format.html { redirect_to accepted_user_friendships_path(@user) }
    end
  end
  
end