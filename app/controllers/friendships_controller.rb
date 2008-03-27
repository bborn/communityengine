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
    @friendship = @user.friendships_not_initiated_by_me.find(params[:id])
 
    respond_to do |format|
      if @friendship.update_attributes(:friendship_status => FriendshipStatus[:denied]) && @friendship.reverse.update_attributes(:friendship_status => FriendshipStatus[:denied])
        flash[:notice] = "The friendship was denied."
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
        flash[:notice] = "The friendship was accepted."
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
    @friendships = @user.friendships.find(:all, :conditions => ["friendship_status_id = ?", FriendshipStatus[:denied].id])
    
    respond_to do |format|
      format.html # index.rhtml
    end
  end


  def accepted
    @user = User.find(params[:user_id])    
    @friend_count = @user.accepted_friendships.count
    @pending_friendships_count = @user.pending_friendships.count
    
    @pages = Paginator.new self, @friend_count, 20, params[:page]
    @friendships = @user.friendships.find(:all, 
        :conditions => ["friendship_status_id = ?", FriendshipStatus[:accepted].id],
        :limit  =>  @pages.items_per_page,
        :offset =>  @pages.current.offset        
      )
    
    respond_to do |format|
      format.html # index.rhtml
    end
  end
  
  def pending
    @user = User.find(params[:user_id])    
    @friendships = @user.friendships.find(:all, :conditions => ["initiator = 0 and friendship_status_id = ?", FriendshipStatus[:pending].id])
    
    respond_to do |format|
      format.html # index.rhtml
    end
  end
  
  # GET /friendships/1
  # GET /friendships/1.xml
  def show
    @friendship = Friendship.find(params[:id])
    @user = @friendship.user
    
    respond_to do |format|
      format.html # show.rhtml
    end
  end
  
  # GET /friendships/1;edit
  def edit
    @user = User.find(params[:user_id])
    @friendship = @user.friendships_not_initiated_by_me.find(params[:id])    
  end

  # POST /friendships
  # POST /friendships.xml
  def create
    @user = User.find(params[:user_id])
    @friendship = Friendship.new(:user_id => params[:user_id], :friend_id => params[:friend_id], :initiator => true )
    @friendship.friendship_status_id = FriendshipStatus[:pending].id    
    reverse_friendship = Friendship.new(params[:friendship])
    reverse_friendship.friendship_status_id = FriendshipStatus[:pending].id 
    reverse_friendship.user_id, reverse_friendship.friend_id = @friendship.friend_id, @friendship.user_id
    
    respond_to do |format|
      if @friendship.save && reverse_friendship.save
        UserNotifier.deliver_friendship_request(@friendship) if @friendship.friend.notify_friend_requests?
        format.html {
          flash[:notice] = "Requested friendship with #{@friendship.friend.login}."
          redirect_to accepted_user_friendships_path(@user)
        }
        format.js { render( :inline => "Requested friendship with #{@friendship.friend.login}." ) }        
      else
        flash.now[:error] = 'Friendship could not be created'
        @users = User.find(:all)
        format.html { redirect_to user_friendships_path(@user) }
        format.js { render( :inline => "Friendship request failed." ) }                
      end
    end
  end
    
  # DELETE /friendships/1
  # DELETE /friendships/1.xml
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