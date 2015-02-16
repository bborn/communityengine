class HomepageFeaturesController < BaseController

  before_action :login_required
  before_action :admin_required

  def index
    @search = HomepageFeature.search(params[:q])
    @homepage_features = @search.result
    @homepage_features = @homepage_features.order('created_at DESC').page(params[:page]).per(100)
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
    @homepage_feature = HomepageFeature.new(homepage_feature_params)

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
      if @homepage_feature.update_attributes(homepage_feature_params)
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

  private

  def homepage_feature_params
    params[:homepage_feature].permit(:url, :title, :description, :image)
  end
end
