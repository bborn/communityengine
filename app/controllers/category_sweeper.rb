class CategorySweeper < ActionController::Caching::Sweeper
  observe Category # This sweeper is going to keep an eye on the Post model

  # If our sweeper detects that a Post was created call this
  def after_create(category)
    expire_cache_for(category)
  end
  
  # If our sweeper detects that a Post was updated call this
  def after_update(category)
    expire_cache_for(category)
  end
  
  # If our sweeper detects that a Post was deleted call this
  def after_destroy(category)
    expire_cache_for(category)
  end
          
  private
  def expire_cache_for(record)
    # Expire the home page
    expire_action(:controller => 'base', :action => 'site_index')
    
    # Also expire the sitemap
    expire_action(:controller => 'sitemap', :action => 'index')
  end
end
