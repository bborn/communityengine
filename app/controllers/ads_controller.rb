class AdsController < BaseController
  before_filter :login_required
  before_filter :admin_required  

  # GET /ads
  # GET /ads.xml
  def index
    @ads = Ad.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @ads.to_xml }
    end
  end

  # GET /ads/1
  # GET /ads/1.xml
  def show
    @ad = Ad.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @ad.to_xml }
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
    @ad = Ad.new(params[:ad])

    respond_to do |format|
      if @ad.save
        flash[:notice] = 'Ad was successfully created.'
        format.html { redirect_to ad_url(@ad) }
        format.xml  { head :created, :location => ad_url(@ad) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ad.errors.to_xml }
      end
    end
  end

  # PUT /ads/1
  # PUT /ads/1.xml
  def update
    @ad = Ad.find(params[:id])

    respond_to do |format|
      if @ad.update_attributes(params[:ad])
        flash[:notice] = 'Ad was successfully updated.'
        format.html { redirect_to ad_url(@ad) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ad.errors.to_xml }
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
end
