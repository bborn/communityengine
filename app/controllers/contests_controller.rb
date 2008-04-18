class ContestsController < BaseController
  before_filter :login_required, :except => [:show]
  before_filter :admin_required, :except => [:show]

  uses_tiny_mce(:options => AppConfig.default_mce_options, :only => [:new, :edit ])
  # GET /contests
  # GET /contests.xml
  def index
    @contests = Contest.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @contests.to_xml }
    end
  end
  
  # GET /contests/1
  # GET /contests/1.xml
  def show
    @contest = Contest.find(params[:id])
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @contest.to_xml }
    end
  end
  
  # GET /contests/new
  def new
    @contest = Contest.new
  end
  
  # GET /contests/1;edit
  def edit
    @contest = Contest.find(params[:id])
  end

  # POST /contests
  # POST /contests.xml
  def create
    @contest = Contest.new(params[:contest])
    
    respond_to do |format|
      if @contest.save
        flash[:notice] = 'Contest was successfully created.'
        
        format.html { redirect_to contest_url(@contest) }
        format.xml do
          headers["Location"] = contest_url(@contest)
          render :nothing => true, :status => "201 Created"
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contest.errors.to_xml }
      end
    end
  end
  
  # PUT /contests/1
  # PUT /contests/1.xml
  def update
    @contest = Contest.find(params[:id])
    
    respond_to do |format|
      if @contest.update_attributes(params[:contest])
        format.html { redirect_to contest_url(@contest) }
        format.xml  { render :nothing => true }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contest.errors.to_xml }        
      end
    end
  end
  
  # DELETE /contests/1
  # DELETE /contests/1.xml
  def destroy
    @contest = Contest.find(params[:id])
    @contest.destroy
    
    respond_to do |format|
      format.html { redirect_to contests_url   }
      format.xml  { render :nothing => true }
    end
  end
end