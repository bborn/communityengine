class OfferingsController < BaseController
  before_filter :find_user, :only => [:replace]
  before_filter :login_required
  before_filter :require_current_user, :only => [:replace, :destroy, :edit, :update]
  
  # GET /offerings
  # GET /offerings.xml
  def index
    @offerings = Offering.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @offerings.to_xml }
    end
  end
  
  # GET /offerings/1
  # GET /offerings/1.xml
  def show
    @offering = Offering.find(params[:id])
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @offering.to_xml }
    end
  end
  
  # GET /offerings/new
  def new
    @offering = Offering.new
  end
  
  # GET /offerings/1;edit
  def edit
    @offering = Offering.find(params[:id])
  end

  # POST /offerings
  # POST /offerings.xml
  def create
    @offering = Offering.new(params[:offering])
    
    respond_to do |format|
      if @offering.save
        flash[:notice] = 'Offering was successfully created.'
        
        format.html { redirect_to user_offering_url(@offering) }
        format.xml do
          headers["Location"] = user_offering_url(@offering)
          render :nothing => true, :status => "201 Created"
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @offering.errors.to_xml }
      end
    end
  end
  
  # PUT /offerings/1
  # PUT /offerings/1.xml
  def update
    @offering = Offering.find(params[:id])
    
    respond_to do |format|
      if @offering.update_attributes(params[:offering])
        format.html { redirect_to user_offering_url(@offering) }
        format.xml  { render :nothing => true }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @offering.errors.to_xml }        
      end
    end
  end
  
  def replace
    @user.offerings.clear
    params[:users_skills].compact.each do |skill_id|
      offering = Offering.new(:skill_id => skill_id)
      offering.user = @user
      offering.save
    end
    
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
  
  # DELETE /offerings/1
  # DELETE /offerings/1.xml
  def destroy
    @user = User.find(params[:user_id])
    @offering = Offering.find(params[:id])
    if @offering.destroy
      flash.now[:notice] = "The service was deleted."
    else
      flash.now[:error] = "Service could not be deleted."
    end
    
    respond_to do |format|
      format.html { redirect_to edit_user_path(@user) }
      format.js   { 
        render :inline => flash[:error], :status => 500 if flash[:error]
        render :nothing => true if flash[:notice]
      }
    end    
  end
end