class MetroAreasController < BaseController
  before_filter :login_required
  before_filter :admin_required

  def index
    @pages, @metro_areas = paginate :metro_areas, :order => "countries.name, metro_areas.name", :include => :country
  end
  
  def show
    @metro_area = MetroArea.find(params[:id])
    
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @metro_area.to_xml }
    end
  end
  
  def new
    @metro_area = MetroArea.new
  end
  
  def edit
    @metro_area = MetroArea.find(params[:id])
  end

  def create
    @metro_area = MetroArea.new(params[:metro_area])
    
    respond_to do |format|
      if @metro_area.save
        flash[:notice] = 'MetroArea was successfully created.'
        
        format.html { redirect_to metro_area_url(@metro_area) }
        format.xml do
          headers["Location"] = metro_area_url(@metro_area)
          render :nothing => true, :status => "201 Created"
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @metro_area.errors.to_xml }
      end
    end
  end
  
  def update
    @metro_area = MetroArea.find(params[:id])
    
    respond_to do |format|
      if @metro_area.update_attributes(params[:metro_area])
        format.html { redirect_to metro_area_url(@metro_area) }
        format.xml  { render :nothing => true }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @metro_area.errors.to_xml }        
      end
    end
  end
  
  def destroy
    @metro_area = MetroArea.find(params[:id])
    @metro_area.destroy
    
    respond_to do |format|
      format.html { redirect_to metro_areas_url   }
      format.xml  { render :nothing => true }
    end
  end
end