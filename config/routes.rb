Rails.application.routes.draw do |map|

  mount_at = CommunityEngine::Engine.config.mount_at

  #Forum routes go first
  map.recent_forum_posts '/forums/recent', :controller => 'sb_posts', :action => 'index'
  map.resources :forums, :sb_posts, :monitorship
  map.resources :sb_posts, :name_prefix => 'all_', :collection => { :search => :get, :monitored => :get }

  %w(forum).each do |attr|
    map.resources :sb_posts, :name_prefix => "#{attr}_", :path_prefix => "/#{attr.pluralize}/:#{attr}_id"
  end

  map.resources :forums do |forum|
    forum.resources :moderators
    forum.resources :topics do |topic|
      topic.resources :sb_posts
      topic.resource :monitorship, :controller => :monitorships
    end
  end
  map.forum_home '/forums', :controller => 'forums', :action => 'index'
  map.resources :topics

  map.connect 'sitemap.xml', :controller => "sitemap", :action => "index", :format => 'xml'
  map.connect 'sitemap', :controller => "sitemap", :action => "index"

  map.home '', :controller => "base", :action => "site_index"

  # Pages
  map.resources :pages, :path_prefix => '/admin', :name_prefix => 'admin_', :except => :show, :member => { :preview => :get }
  map.pages "pages/:id", :controller => 'pages', :action => 'show'

  # admin routes
  map.admin_dashboard   '/admin/dashboard', :controller => 'homepage_features', :action => 'index'
  map.admin_users       '/admin/users', :controller => 'admin', :action => 'users'
  map.admin_messages    '/admin/messages', :controller => 'admin', :action => 'messages'
  map.admin_comments    '/admin/comments', :controller => 'admin', :action => 'comments'
  map.admin_tags        'admin/tags/:action', :controller => 'tags', :defaults => {:action=>:manage}
  map.admin_events      'admin/events', :controller => 'admin', :action=>'events'

  # sessions routes
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.signup_by_id '/signup/:inviter_id/:inviter_code', :controller => 'users', :action => 'new'

  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.forgot_username '/forgot_username', :controller => 'users', :action => 'forgot_username'  
  map.resend_activation '/resend_activation', :controller => 'users', :action => 'resend_activation'  

  #clippings routes
  map.connect '/new_clipping', :controller => 'clippings', :action => 'new_clipping'
  map.site_clippings '/clippings', :controller => 'clippings', :action => 'site_index'
  map.rss_site_clippings '/clippings.rss', :controller => 'clippings', :action => 'site_index', :format => 'rss'

  map.featured '/featured', :controller => 'posts', :action => 'featured'
  map.featured_rss '/featured.rss', :controller => 'posts', :action => 'featured', :format => 'rss'
  map.popular '/popular', :controller => 'posts', :action => 'popular'
  map.popular_rss '/popular.rss', :controller => 'posts', :action => 'popular', :format => 'rss'
  map.recent '/recent', :controller => 'posts', :action => 'recent'
  map.recent_rss '/recent.rss', :controller => 'posts', :action => 'recent', :format => 'rss'
  map.rss_redirect '/rss', :controller => 'base', :action => 'rss_site_index'
  map.rss '/site_index.rss', :controller => 'base', :action => 'site_index', :format => 'rss'

  map.advertise '/advertise', :controller => 'base', :action => 'advertise'
  map.css_help '/css_help', :controller => 'base', :action => 'css_help'  
  map.about '/about', :controller => 'base', :action => 'about'
  map.faq '/faq', :controller => 'base', :action => 'faq'

  map.edit_account_from_email '/account/edit', :controller => 'users', :action => 'edit_account'

  map.friendships_xml '/friendships.xml', :controller => 'friendships', :action => 'index', :format => 'xml'
  map.friendships '/friendships', :controller => 'friendships', :action => 'index'

  map.manage_photos 'manage_photos', :controller => 'photos', :action => 'manage_photos'
  map.create_photo 'create_photo.js', :controller => 'photos', :action => 'create', :format => 'js'

  map.resources :sessions
  map.resources :statistics, :collection => {:activities => :get, :activities_chart => :get}
  map.resources :tags, :member_path => '/tags/:id'
  map.show_tag_type '/tags/:id/:type', :controller => 'tags', :action => 'show'
  map.search_tags '/search/tags', :controller => 'tags', :action => 'show'

  map.resources :categories
  map.resources :skills
  map.resources :events, :collection => { :past => :get, :ical => :get }, :member => { :clone => :get } do |event|
    event.resources :rsvps, :except => [:index, :show]
  end
  map.resources :favorites, :path_prefix => '/:favoritable_type/:favoritable_id'
  map.resources :comments, :path_prefix => '/:commentable_type/:commentable_id'
  map.delete_selected_comments 'comments/delete_selected', :controller => "comments", :action => 'delete_selected'

  map.resources :homepage_features
  map.resources :metro_areas
  map.resources :ads
  map.resources :contests, :collection => { :current => :get }
  map.resources :activities

  map.resources :users, :member_path => '/:id', :nested_member_path => '/:user_id', :member => { 
      :dashboard => :get,
      :assume => :get,
      :toggle_moderator => :put,
      :toggle_featured => :put,
      :change_profile_photo => :put,
      :return_admin => :get, 
      :edit_account => :get,
      :update_account => :put,
      :edit_pro_details => :get,
      :update_pro_details => :put,      
      :forgot_password => [:get, :post],
      :signup_completed => :get,
      :invite => :get,
      :welcome_photo => :get, 
      :welcome_about => :get, 
      :welcome_stylesheet => :get, 
      :welcome_invite => :get,
      :welcome_complete => :get,
      :statistics => :any,
      :deactivate => :put,
      :crop_profile_photo => [:get, :put],
      :upload_profile_photo => [:get, :put]
       } do |user|
    user.resources :friendships, :member => { :accept => :put, :deny => :put }, :collection => { :accepted => :get, :pending => :get, :denied => :get }
    user.resources :photos, :collection => {:swfupload => :post, :slideshow => :get}
    user.resources :posts, :collection => {:manage => :get}, :member => {:contest => :get, :send_to_friend => :any, :update_views => :any}
    user.resources :events # Needed this to make comments work
    user.resources :clippings
    user.resources :activities, :collection => {:network => :get}
    user.resources :invitations
    user.resources :offerings, :collection => {:replace => :put}
    user.resources :favorites, :name_prefix => 'user_'
    user.resources :messages, :collection => { :delete_selected => :post, :auto_complete_for_username => :any }  
    user.resources :comments
    user.resources :photo_manager, :only => ['index']
    user.resources :albums, :path_prefix => ':user_id/photo_manager', :member => {:add_photos => :get, :photos_added => :post}, :collection => {:paginate_photos => :get}  do |album| 
      album.resources :photos, :collection => {:swfupload => :post, :slideshow => :get}
    end
  end
  map.resources :votes
  map.resources :invitations

  map.users_posts_in_category '/users/:user_id/posts/category/:category_name', :controller => 'posts', :action => 'index', :category_name => :category_name

  # with_options(:controller => 'theme', :filename => /.*/, :conditions => {:method => :get}) do |theme|
  #   theme.connect 'stylesheets/theme/:filename', :action => 'stylesheets'
  #   theme.connect 'javascripts/theme/:filename', :action => 'javascript'
  #   theme.connect 'images/theme/:filename',      :action => 'images'
  # end

  # # Deprecated routes
  # deprecated_popular_rss '/popular_rss', :controller => 'base', :action => 'popular', :format => 'rss'    
  # deprecated_category_rss '/categories/:id;rss', :controller => 'categories', :action => 'show', :format => 'rss'  
  # deprecated_posts_rss '/:user_id/posts;rss', :controller => 'posts', :action => 'index', :format => 'rss'

end



