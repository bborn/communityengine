class StaticPagesController < BaseController
  uses_tiny_mce(:options => AppConfig.default_mce_options, :only => [:new, :edit ])
  before_filter :admin_required, :except => [:show_web]
  
  def index
    @static_pages = StaticPage.all
  end
  
  def show
    @static_page = StaticPage.find(params[:id])
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @static_page }
    end
  end

  def new
    @static_page = StaticPage.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @static_page }
    end
  end

  def edit
    @static_page = StaticPage.find(params[:id])
  end

  def create
    @static_page = StaticPage.new(params[:static_page])

    respond_to do |format|
      if @static_page.save
        flash[:notice] = 'Static page was successfully created.'
        format.html { redirect_to(@static_page) }
        format.xml  { render :xml => @static_page, :status => :created, :location => @static_page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @static_page.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @static_page = StaticPage.find(params[:id])

    respond_to do |format|
      if @static_page.update_attributes(params[:static_page])
        flash[:notice] = 'Static page was successfully updated.'
        format.html { redirect_to(@static_page) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @static_page.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @static_page = StaticPage.find(params[:id])
    @static_page.destroy

    respond_to do |format|
      format.html { redirect_to(static_pages_url) }
      format.xml  { head :ok }
    end
  end  
  
  def show_web
    @static_page = StaticPage.find_by_url(params[:url])
    if @static_page.active == false
      redirect_to ('/')
      return
    end
    case @static_page.visibility
      when 'Users'
        login_required
        return
      when 'Admin'
        admin_required
        return
    end
  
  end
end