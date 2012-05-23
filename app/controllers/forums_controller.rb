class ForumsController < BaseController
  before_filter :admin_required, :except => [:index, :show]
  before_filter :find_or_initialize_forum

  uses_tiny_mce do    
    {:options => configatron.default_mce_options}
  end
  
  def index
    @forums = Forum.find(:all, :order => "position")
    respond_to do |format|
      format.html
      format.xml { render :xml => @forums }
    end
  end

  def show
    respond_to do |format|
      format.html do
        # keep track of when we last viewed this forum for activity indicators
        (session[:forums] ||= {})[@forum.id] = Time.now.utc if logged_in?

        @topics = @forum.topics.includes(:replied_by_user).order('sticky DESC, replied_at DESC').page(params[:page]).per(20)
      end
      
      format.xml do
        render :xml => @forum
      end
    end
  end
  
  def create
    @forum.tag_list = params[:tag_list] || ''
    @forum.save!
    respond_to do |format|
      format.html { redirect_to forums_path }
      format.xml  { head :created, :location => forum_url(:id => @forum, :format => :xml) }
    end
  end

  def update
    @forum.tag_list = params[:tag_list] || ''
    @forum.name = params[:forum][:name]
    @forum.position = params[:forum][:position]
    @forum.description = params[:forum][:description]
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
      if params[:id]
        @forum = Forum.find(params[:id])
      else
        @forum = Forum.new
        if params[:forum]
          @forum.name = params[:forum][:name]
          @forum.position = params[:forum][:position]
          @forum.description = params[:forum][:description]
        end
      end
    end
    
    
end
