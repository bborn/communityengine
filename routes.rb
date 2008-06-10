#Forum routes go first
resources :forums, :topics, :sb_posts, :monitorship
resources :sb_posts, :name_prefix => 'all_', :collection => { :search => :get, :monitored => :get }

%w(forum).each do |attr|
  resources :sb_posts, :name_prefix => "#{attr}_", :path_prefix => "/#{attr.pluralize}/:#{attr}_id"
end

resources :forums do |forum|
  forum.resources :moderators
  forum.resources :topics do |topic|
    topic.resources :sb_posts
    topic.resource :monitorship, :controller => :monitorships
  end
end
forum_home '/forums', :controller => 'forums', :action => 'index'

connect 'sitemap.xml', :controller => "sitemap", :action => "index", :format => 'xml'
connect 'sitemap', :controller => "sitemap", :action => "index"

if AppConfig.closed_beta_mode
  connect '', :controller => "base", :action => "teaser"
  home 'home', :controller => "base", :action => "site_index"
else
  home '', :controller => "base", :action => "site_index"
end
connect '/application/:action', :controller => 'base'

# admin routes
admin_dashboard '/admin/dashboard', :controller => 'homepage_features', :action => 'index'

# sessions routes
login  '/login',  :controller => 'sessions', :action => 'new'
signup '/signup', :controller => 'users', :action => 'new'
logout '/logout', :controller => 'sessions', :action => 'destroy'
signup_by_id '/signup/:inviter_id/:inviter_code', :controller => 'users', :action => 'new'

forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
forgot_username '/forgot_username', :controller => 'users', :action => 'forgot_username'  

#clippings routes
connect '/new_clipping', :controller => 'clippings', :action => 'new_clipping'
site_clippings '/clippings', :controller => 'clippings', :action => 'site_index'
rss_site_clippings '/clippings.rss', :controller => 'clippings', :action => 'site_index', :format => 'rss'

featured '/featured', :controller => 'posts', :action => 'featured'
featured_rss '/featured.rss', :controller => 'posts', :action => 'featured', :format => 'rss'
popular '/popular', :controller => 'posts', :action => 'popular'
popular_rss '/popular.rss', :controller => 'posts', :action => 'popular', :format => 'rss'
recent '/recent', :controller => 'posts', :action => 'recent'
recent_rss '/recent.rss', :controller => 'posts', :action => 'recent', :format => 'rss'
rss_redirect '/rss', :controller => 'base', :action => 'rss_site_index'
rss '/site_index.rss', :controller => 'base', :action => 'site_index', :format => 'rss'

about '/about', :controller => 'base', :action => 'about'
advertise '/advertise', :controller => 'base', :action => 'advertise'
faq '/faq', :controller => 'base', :action => 'faq'
css_help '/css_help', :controller => 'base', :action => 'css_help'  

edit_account_from_email '/account/edit', :controller => 'users', :action => 'edit_account'

users_posts_in_category '/users/:user_id/posts/category/:category_name', :controller => 'posts', :action => 'index', :category_name => :category_name

friendships_xml '/friendships.xml', :controller => 'friendships', :action => 'index', :format => 'xml'
friendships '/friendships', :controller => 'friendships', :action => 'index'

manage_photos 'manage_photos', :controller => 'photos', :action => 'manage_photos'
create_photo 'create_photo.js', :controller => 'photos', :action => 'create', :format => 'js'

resources :sessions
resources :statistics, :collection => {:activities => :get, :activities_chart => :get}
resources :tags, :member_path => '/tags/:id'
search_tags '/search/tags', :controller => 'tags', :action => 'show'

resources :categories
resources :skills
resources :events
resources :favorites, :path_prefix => '/:favoritable_type/:favoritable_id'
resources :comments, :path_prefix => '/:commentable_type/:commentable_id'
resources :homepage_features
resources :metro_areas
resources :ads
resources :contests, :member => { :latest => :get }

resources :users, :member_path => '/:id', :nested_member_path => '/:user_id', :member => { 
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
    :statistics => :any
     } do |user|
  user.resources :friendships, :member => { :accept => :put, :deny => :put }, :collection => { :accepted => :get, :pending => :get, :denied => :get }
  user.resources :photos, :collection => {:swfupload => :post, :slideshow => :get}
  user.resources :posts, :collection => {:manage => :get}, :member => {:contest => :get, :send_to_friend => :any, :update_views => :any}
  user.resources :clippings
  user.resources :activities, :collection => {:network => :get}
  user.resources :invitations
  user.resources :offerings, :collection => {:replace => :put}
  user.resources :favorites, :name_prefix => 'user_'
end
resources :votes

with_options(:controller => 'theme', :filename => /.*/, :conditions => {:method => :get}) do |theme|
  theme.connect 'stylesheets/theme/:filename', :action => 'stylesheets'
  theme.connect 'javascripts/theme/:filename', :action => 'javascript'
  theme.connect 'images/theme/:filename',      :action => 'images'
end

# Deprecated routes
deprecated_popular_rss '/popular_rss', :controller => 'base', :action => 'popular', :format => 'rss'    
deprecated_category_rss '/categories/:id;rss', :controller => 'categories', :action => 'show', :format => 'rss'  
deprecated_posts_rss '/:user_id/posts;rss', :controller => 'posts', :action => 'index', :format => 'rss'