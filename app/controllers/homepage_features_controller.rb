class HomepageFeaturesController < BaseController
  uses_tiny_mce do
    {:only => [:new, :edit, :create, :update ], :options => configatron.default_mce_options}
  end

  before_filter :login_required
  before_filter :admin_required

  def index
    @search = HomepageFeature.search(params[:search])
    @search.order ||= :descend_by_created_at
    @homepage_features = @search.page(params[:page]).per(100)
    respond_to do |format|
      format.html
    end
  end
  
  def show
    @homepage_feature = HomepageFeature.find(params[:id])
    
    respond_to do |format|
      format.html 
    end
  end
  
  def new
    @homepage_feature = HomepageFeature.new
  end
  
  def edit
    @homepage_feature = HomepageFeature.find(params[:id])
  end

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
  
  def destroy
    @homepage_feature = HomepageFeature.find(params[:id])
    @homepage_feature.destroy
    
    respond_to do |format|
      format.html { redirect_to homepage_features_url   }
    end
  end
end