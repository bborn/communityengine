class PagesController < BaseController
  uses_tiny_mce(:only => [:new, :edit, :update, :create ]) do
    configatron.default_mce_options
  end

  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]
  caches_action :show, :if => Proc.new{|c| c.cache_action? }

  def cache_action?
    !logged_in? && controller_name.eql?('pages')
  end 

  before_filter :login_required, :only => [:index, :new, :edit, :update, :destroy, :create, :preview]
  before_filter :require_moderator, :only => [:index, :new, :edit, :update, :destroy, :create, :preview]

  def index
    @pages = Page.find_without_published_as(:all, :order => 'created_at DESC')
  end

  def preview
    @page = Page.find(params[:id])
    render :action => :show
  end

  def show
    @page = Page.live.find(params[:id])
    unless logged_in? || @page.page_public
      flash[:error] = :page_not_public_warning.l
      redirect_to :controller => 'sessions', :action => 'new'      
    end
  rescue
    flash[:error] = :page_not_found.l
    redirect_to home_path
  end

  def create
    @page = Page.new(params[:page])
    if @page.save
      flash[:notice] = :page_was_successfully_created.l
      redirect_to admin_pages_path
    else
      render :action => :new
    end
  end

  def update
    if @page.update_attributes(params[:page])
      flash[:notice] = :page_was_successfully_updated.l
      redirect_to admin_pages_path
    else
      render :action => :edit
    end
  end

  def destroy
    @page.destroy
    flash[:notice] = :page_was_successfully_deleted.l
    redirect_to admin_pages_path
  end

  private
  
  def require_moderator
    @page ||= Page.find(params[:id]) if params[:id]
    unless admin? || moderator?
      redirect_to :controller => 'sessions', :action => 'new' and return false
    end
  end

end
