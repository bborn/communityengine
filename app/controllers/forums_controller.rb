class ForumsController < BaseController
  before_filter :login_required, :except => [:index, :show]
  before_filter :find_or_initialize_forum
  helper :application
  uses_tiny_mce :options => AppConfig.default_mce_options
  
  def index
    @forums = Forum.find(:all, :order => "position")
    respond_to do |format|
      format.html
      format.xml { render :xml => @forums.to_xml }
    end
  end

  def show
    respond_to do |format|
      format.html do
        # keep track of when we last viewed this forum for activity indicators
        (session[:forums] ||= {})[@forum.id] = Time.now.utc if logged_in?

        @topics = @forum.topics.find(:all, 
          :page => {:size => 2, :current => params[:page]}, 
          :include => :replied_by_user, 
          :order => 'sticky DESC, replied_at DESC')
      end
      
      format.xml do
        render :xml => @forum.to_xml
      end
    end
  end

  # new renders new.rhtml
  
  def create
    @forum.attributes = params[:forum]
    @forum.tag_list = params[:tag_list] || ''
    @forum.save!
    respond_to do |format|
      format.html { redirect_to forums_path }
      format.xml  { head :created, :location => formatted_forum_url(:id => @forum, :format => :xml) }
    end
  end

  def update
    @forum.attributes = params[:forum]
    @forum.tag_list = params[:tag_list] || ''
    @forum.save!
    respond_to do |format|
      format.html { redirect_to forums_path }
      format.xml  { head 200 }
    end
  end
  
  def destroy
    @forum.destroy
    respond_to do |format|
      format.html { redirect_to forums_path }
      format.xml  { head 200 }
    end
  end
  
  protected
    def find_or_initialize_forum
      @forum = params[:id] ? Forum.find(params[:id]) : Forum.new
    end

  #overide in your app
  def authorized?
    current_user.admin?
  end
end
