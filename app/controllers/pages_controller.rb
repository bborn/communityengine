class PagesController < BaseController

  caches_action :show, :if => Proc.new{|c| c.cache_action? }

  def cache_action?
    !logged_in? && controller_name.eql?('pages')
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

end
