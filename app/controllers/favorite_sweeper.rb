class FavoriteSweeper < ActionController::Caching::Sweeper
  observe Favorite

  def after_create(favorite)
    expire_cache_for(favorite)
  end
    
  def after_destroy(favorite)
    expire_cache_for(favorite)
  end
          
  private
  def expire_cache_for(record)
    #the favorite is for a post
    if record.favoritable_type.eql?('Post')
      # expire the show page
      expire_page :controller => 'posts', :action => 'show', :id => record.favoritable, :user_id => record.favoritable.user
      
      if Post.find_recent(:limit => 16).include?(record.favoritable)
        # Expire the home page
        expire_action :controller => 'base', :action => 'site_index'

        # Expire the category page for this post
        expire_action :controller => 'categories', :action => 'show', :id => record.favoritable.category
      end
    end
        
  end
end