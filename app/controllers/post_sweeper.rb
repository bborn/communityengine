class PostSweeper < ActionController::Caching::Sweeper
  observe Post # This sweeper is going to keep an eye on the Post model

  # If our sweeper detects that a Post was created call this
  def after_create(post)
    expire_cache_for(post)
  end
  
  # If our sweeper detects that a Post was updated call this
  def after_update(post)
    expire_cache_for(post)
  end
  
  # If our sweeper detects that a Post was deleted call this
  def after_destroy(post)
    expire_cache_for(post)
  end
          
  private
  def expire_cache_for(record)
    # Expire the home page
    expire_action(:controller => 'base', :action => 'site_index')

    # Expire the footer content
    expire_action(:controller => 'base', :action => 'footer_content')
    
    # Also expire the sitemap
    expire_page(:controller => 'sitemap', :action => 'index')

    # Expire the category pages
    expire_page(:controller => 'categories', :action => 'show')

    # Also expire the show pages, incase we just edited a blog entry
    expire_page(:controller => 'posts', :action => 'show')
  end
end