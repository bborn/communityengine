Rails.application.routes.draw do
  get '/base/:action' => 'base'

  get '/forums/recent' => 'sb_posts#index', :as => :recent_forum_posts

  resources :authorizations
  match '/auth/:provider/callback' => 'authorizations#create', :as => :callback
  get '/auth/failure' => 'authorizations#failure'
  
  resources :sb_posts, :as => 'all_sb_posts' do
    collection do
      get :search
      get :monitored
    end
  end
    
  resources :monitorship
  resources :sb_posts do
    collection do
      get :search
      get :monitored
    end
  end

  resources :forums do
    resources :sb_posts
    
    resources :moderators
    resources :topics do
      resources :sb_posts
      resource :monitorship
    end
  end

  get '/forums' => 'forums#index', :as => :forum_home

  get 'sitemap.xml' => 'sitemap#index', :format => 'xml'
  get 'sitemap' => 'sitemap#index'
  
  get '/' => 'base#site_index', :as => :home
  
  scope "/admin" do
    get 'dashboard' => 'homepage_features#index', :as => :admin_dashboard
    get 'users' => 'admin#users', :as => :admin_users
    get 'messages' => 'admin#messages', :as => :admin_messages
    get 'comments' => 'admin#comments', :as => :admin_comments
    get 'tags' => 'tags#manage', :as => :admin_tags
    get 'events' => 'admin#events', :as => :admin_events
    get 'clear_cache' => 'admin#clear_cache', :as => :admin_clear_cache
    get 'subscribers(.:format)' => "admin#subscribers", :as => :admin_subscribers
    
    resources :pages, :as => :admin_pages do
      member do
        get :preview
      end
    end
  end
  
  get 'pages/:id' => 'pages#show', :as => :pages
  
  
  get '/login' => 'sessions#new', :as => :login
  get '/signup' => 'users#new', :as => :signup
  get '/logout' => 'sessions#destroy', :as => :logout
  
  get '/signup/:inviter_id/:inviter_code' => 'users#new', :as => :signup_by_id
  get '/forgot_password' => 'password_resets#new', :as => :forgot_password
  resources :password_resets
  get '/forgot_username' => 'users#forgot_username', :as => :forgot_username
  post '/resend_activation' => 'users#resend_activation', :as => :resend_activation
  
  get '/new_clipping' => 'clippings#new_clipping'
  get '/clippings(/page/:page)' => 'clippings#site_index', :as => :site_clippings
  get '/clippings.rss' => 'clippings#site_index', :as => :rss_site_clippings, :format => 'rss'
  
  get '/featured(/page/:page)' => 'posts#featured', :as => :featured
  get '/featured.rss' => 'posts#featured', :as => :featured_rss, :format => 'rss'
  get '/popular(/page/:page)' => 'posts#popular', :as => :popular
  get '/popular.rss' => 'posts#popular', :as => :popular_rss, :format => 'rss'
  get '/recent(/page/:page)' => 'posts#recent', :as => :recent
  get '/recent.rss' => 'posts#recent', :as => :recent_rss, :format => 'rss'
  get '/rss' => 'base#rss_site_index', :as => :rss_redirect
  get '/site_index.rss' => 'base#site_index', :as => :rss, :format => 'rss'
  get '/advertise' => 'base#advertise', :as => :advertise
  get '/css_help' => 'base#css_help', :as => :css_help
  get '/about' => 'base#about', :as => :about
  get '/faq' => 'base#faq', :as => :faq
  get '/footer_content' => 'base#footer_content', :as => :footer_content

  get '/account/edit' => 'users#edit_account', :as => :edit_account_from_email

  get '/friendships.xml' => 'friendships#index', :as => :friendships_xml, :format => 'xml'
  get '/friendships' => 'friendships#index', :as => :friendships

  get 'manage_photos' => 'photos#manage_photos', :as => :manage_photos
  post 'create_photo.js' => 'photos#create', :as => :create_photo, :format => 'js'

  resources :sessions
  resources :statistics do
    collection do
      get :activities
      get :activities_chart
    end
  end

  resources :tags
  get '/tags/:id/:type' => 'tags#show', :as => :show_tag_type
  get '/search/tags' => 'tags#show', :as => :search_tags
  resources :categories
  
  resources :events do
    get 'page/:page', :action => :index, :on => :collection
    collection do
      get :past
      get :ical
    end
    member do
      get :clone
    end
    resources :rsvps
  end

  scope '/:favoritable_type/:favoritable_id' do
    resources :favorites
  end
  scope "/:commentable_type/:commentable_id" do
    resources :comments, :as => :commentable_comments
  end
  delete '/comments/delete_selected' => 'comments#delete_selected', :as => :delete_selected_comments
  
  resources :homepage_features
  resources :metro_areas
  resources :ads

  resources :activities
  
  resources :users do
    
    get 'page/:page', :action => :index, :on => :collection
    
    collection do
      post 'return_admin'
      delete 'delete_selected'
    end
    member do
      get 'dashboard'
      get 'edit_account'
      get 'invite'
      get 'signup_completed'      
      get 'activate'
      
      put 'toggle_moderator'
      put 'toggle_featured'

      put 'change_profile_photo'
      put 'update_account'
      put 'deactivate'      
      
      get 'welcome_photo'
      get 'welcome_about'
      get 'welcome_invite'
      get 'welcome_complete'
      
      post 'assume'               
      
      get 'statistics'
      put 'crop_profile_photo'
      put 'upload_profile_photo'
      get 'metro_area_update'
    end
    
    resources :friendships do
      collection do
        get :accepted
        get :pending
        get :denied
      end
      member do
        put :accept
        put :deny
      end
    end

    resources :photos do
      get 'page/:page', :action => :index, :on => :collection
    end

    resources :posts do
      get 'page/:page', :action => :index, :on => :collection            
      
      collection do 
        # get 'manage(/page/:page)', :action => :manage
        get :manage
      end
      
      member do
        post :send_to_friend
        put :update_views
      end
    end

    resources :clippings

    resources :activities do
      get 'page/:page', :action => :index, :on => :collection  
      collection do
        get :network
      end
    end

    resources :invitations

    resources :favorites
    resources :messages do
      post :auto_complete_for_username, :on => :collection
      collection do
        post :delete_message_threads
        post :delete_selected

      end
    end

    resources :comments
    resources :photo_manager

    resources :albums do
      resources :photos do
        collection do
          post :swfupload
          get :slideshow
        end
      end
    end

  end

  resources :votes
  resources :invitations
  get '/users/:user_id/posts/category/:category_name' => 'posts#index', :as => :users_posts_in_category

end
