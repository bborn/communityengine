class TaggableSweeper < ActionController::Caching::Sweeper
  observe User, Post, Clipping, Photo # This sweeper is going to keep an eye on taggable models

  # If our sweeper detects that a taggable (User) was activated 
  def after_activate(taggable)
    expire_cache_for(taggable)
  end

  # If our sweeper detects that a taggable was created
  def after_create(taggable)
    expire_cache_for(taggable)
  end

  # If our sweeper detects that a photo was uploaded
  def after_swfupload(photo)
    expire_cache_for(taggable)    
  end
  
  # If our sweeper detects that a taggable was updated 
  def after_update(taggable)
    expire_cache_for(taggable)
  end
  
  # If our sweeper detects that a taggable was deleted
  def after_destroy(taggable)
    expire_cache_for(taggable)
  end
          
  private
  def expire_cache_for(record)
    # Expire the tag show pages
    record.tags.each do |tag|
      expire_action(tag_url(tag))
    end
  end
  
  
end