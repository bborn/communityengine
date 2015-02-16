class AdsController < BaseController

  before_action :login_required
  before_action :admin_required

  # GET /ads
  # GET /ads.xml
  def index
    @search = Ad.search(params[:q])
    @result = @search.result
    @ads = @result.order('created_at DESC').distinct
    @ads = @result.page(params[:page]).per(15)

    respond_to do |format|
      format.html
    end
  end

  # GET /ads/1
  # GET /ads/1.xml
  def show
    @ad = Ad.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  # GET /ads/new
  def new
    @ad = Ad.new
  end

  # GET /ads/1;edit
  def edit
    @ad = Ad.find(params[:id])
  end

  # POST /ads
  # POST /ads.xml
  def create
    @ad = Ad.new(ad_params)

    respond_to do |format|
      if @ad.save
        flash[:notice] = :ad_was_successfully_created.l
        format.html { redirect_to ad_url(@ad) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /ads/1
  # PUT /ads/1.xml
  def update
    @ad = Ad.find(params[:id])

    respond_to do |format|
      if @ad.update_attributes(ad_params)
        flash[:notice] = :ad_was_successfully_updated.l
        format.html { redirect_to ad_url(@ad) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /ads/1
  # DELETE /ads/1.xml
  def destroy
    @ad = Ad.find(params[:id])
    @ad.destroy

    respond_to do |format|
      format.html { redirect_to ads_url }
      format.xml  { head :ok }
    end
  end

  private

  def ad_params
    params[:ad].permit(:html, :name, :frequency, :audience, :published, :time_constrained, :start_date, :end_date, :location)
  end
end
