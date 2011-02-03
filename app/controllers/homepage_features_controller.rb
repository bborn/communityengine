class HomepageFeaturesController < BaseController
  uses_tiny_mce(:only => [:new, :edit ]) do
    configatron.default_mce_options
  end

  before_filter :login_required
  before_filter :admin_required
  # GET /homepage_features
  # GET /homepage_features.xml
  def index
    
    @search = HomepageFeature.search(params[:search])
    @search.order ||= :descend_by_created_at
    
    @homepage_features = @search.find(:all, :conditions => ["parent_id IS NULL"], :page => {:current => params[:page], :size => 100})    
    
    respond_to do |format|
      format.html # index.rhtml
    end
  end
  
  # GET /homepage_features/1
  # GET /homepage_features/1.xml
  def show
    @homepage_feature = HomepageFeature.find(params[:id])
    
    respond_to do |format|
      format.html # show.rhtml
    end
  end
  
  # GET /homepage_features/new
  def new
    @homepage_feature = HomepageFeature.new
  end
  
  # GET /homepage_features/1;edit
  def edit
    @homepage_feature = HomepageFeature.find(params[:id])
  end

  # POST /homepage_features
  # POST /homepage_features.xml
  def create
    @homepage_feature = HomepageFeature.new(params[:homepage_feature])
    
    respond_to do |format|
      if @homepage_feature.save
        flash[:notice] = :homepage_feature_created.l
        
        format.html { redirect_to homepage_feature_url(@homepage_feature) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  # PUT /homepage_features/1
  # PUT /homepage_features/1.xml
  def update
    @homepage_feature = HomepageFeature.find(params[:id])
    
    respond_to do |format|
      if @homepage_feature.update_attributes(params[:homepage_feature])
        format.html { redirect_to homepage_feature_url(@homepage_feature) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  # DELETE /homepage_features/1
  # DELETE /homepage_features/1.xml
  def destroy
    @homepage_feature = HomepageFeature.find(params[:id])
    @homepage_feature.destroy
    
    respond_to do |format|
      format.html { redirect_to homepage_features_url   }
    end
  end
end