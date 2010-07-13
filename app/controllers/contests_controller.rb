class ContestsController < BaseController
  before_filter :login_required, :except => [:show, :current]
  before_filter :admin_required, :except => [:show, :current, :index]

  uses_tiny_mce(:only => [:new, :edit ]) do
    AppConfig.default_mce_options
  end
  
  def current
    @contest = Contest.current
    redirect_to :action => "index" and return unless @contest    
    render :action => 'show'
  end


  def index
    @contests = Contest.find(:all)

    respond_to do |format|
      format.html
    end
  end
  
  def show
    @contest = Contest.find(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @contest = Contest.new
  end
  
  def edit
    @contest = Contest.find(params[:id])
  end

  def create
    @contest = Contest.new(params[:contest])
    
    respond_to do |format|
      if @contest.save
        flash[:notice] = :contest_was_successfully_created.l
        
        format.html { redirect_to contest_url(@contest) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @contest = Contest.find(params[:id])
    
    respond_to do |format|
      if @contest.update_attributes(params[:contest])
        format.html { redirect_to contest_url(@contest) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @contest = Contest.find(params[:id])
    @contest.destroy
    
    respond_to do |format|
      format.html { redirect_to contests_url   }
    end
  end
end