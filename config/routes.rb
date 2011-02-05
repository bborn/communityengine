Rails.application.routes.draw do
  match '/forums/recent' => 'sb_posts#index', :as => :recent_forum_posts
  
  resources :sb_posts, :as => 'all_sb_posts' do
    collection do
      get :search
      get :monitored
    end
  end
  
  match '/base/:action' => 'base'
  
  resources :monitorship
  resources :sb_posts do
    collection do
      get :search
      get :monitored
    end
  end

  resources :forums do
    resources :moderators
    resources :topics do
      resources :sb_posts
      resource :monitorship
    end
  end

  match '/forums' => 'forums#index', :as => :forum_home

  match 'sitemap.xml' => 'sitemap#index', :format => 'xml'
  match 'sitemap' => 'sitemap#index'
  
  match '/' => 'base#site_index', :as => :home
  
  resources :pages do
    member do
      get :preview
    end
  end
  match 'pages/:id' => 'pages#show', :as => :pages
  
  match '/admin/dashboard' => 'homepage_features#index', :as => :admin_dashboard
  match '/admin/users' => 'admin#users', :as => :admin_users
  match '/admin/messages' => 'admin#messages', :as => :admin_messages
  match '/admin/comments' => 'admin#comments', :as => :admin_comments
  match '/admin/tags/:action' => 'tags#index', :as => :admin_tags, :defaults => { :action => "manage" }
  match '/admin/events' => 'admin#events', :as => :admin_events
  match '/admin/clear_cache' => 'admin#clear_cache', :as => :admin_clear_cache
  
  match '/login' => 'sessions#new', :as => :login
  match '/signup' => 'users#new', :as => :signup
  match '/logout' => 'sessions#destroy', :as => :logout
  
  match '/signup/:inviter_id/:inviter_code' => 'users#new', :as => :signup_by_id
  match '/forgot_password' => 'password_resets#new', :as => :forgot_password
  resources :password_resets
  match '/forgot_username' => 'users#forgot_username', :as => :forgot_username
  match '/resend_activation' => 'users#resend_activation', :as => :resend_activation
  
  match '/new_clipping' => 'clippings#new_clipping'
  match '/clippings' => 'clippings#site_index', :as => :site_clippings
  match '/clippings.rss' => 'clippings#site_index', :as => :rss_site_clippings, :format => 'rss'
  
  match '/featured' => 'posts#featured', :as => :featured
  match '/featured.rss' => 'posts#featured', :as => :featured_rss, :format => 'rss'
  match '/popular' => 'posts#popular', :as => :popular
  match '/popular.rss' => 'posts#popular', :as => :popular_rss, :format => 'rss'
  match '/recent' => 'posts#recent', :as => :recent
  match '/recent.rss' => 'posts#recent', :as => :recent_rss, :format => 'rss'
  match '/rss' => 'base#rss_site_index', :as => :rss_redirect
  match '/site_index.rss' => 'base#site_index', :as => :rss, :format => 'rss'
  match '/advertise' => 'base#advertise', :as => :advertise
  match '/css_help' => 'base#css_help', :as => :css_help
  match '/about' => 'base#about', :as => :about
  match '/faq' => 'base#faq', :as => :faq

  match '/account/edit' => 'users#edit_account', :as => :edit_account_from_email

  match '/friendships.xml' => 'friendships#index', :as => :friendships_xml, :format => 'xml'
  match '/friendships' => 'friendships#index', :as => :friendships

  match 'manage_photos' => 'photos#manage_photos', :as => :manage_photos
  match 'create_photo.js' => 'photos#create', :as => :create_photo, :format => 'js'

  resources :sessions
  resources :statistics do
    collection do
      get :activities
      get :activities_chart
    end
  end

  resources :tags
  match '/tags/:id/:type' => 'tags#show', :as => :show_tag_type
  match '/search/tags' => 'tags#show', :as => :search_tags
  resources :categories
  resources :skills
  resources :events do
    resources :rsvps
  end

  resources :favorites
  resources :comments
  match 'comments/delete_selected' => 'comments#delete_selected', :as => :delete_selected_comments
  resources :homepage_features
  resources :metro_areas
  resources :ads
  resources :contests do
    collection do
      get :current
    end
  end

  resources :activities
  
  resources :users do
    member do
      get 'dashboard'
      get 'assume'
      get 'return_admin'      
      get 'edit_account'
      get 'invite'

      get 'signup_completed'      
      
      put 'toggle_moderator'
      put 'toggle_featured'

      put 'change_profile_photo'
      put 'update_account'
      put 'deactivate'      
      
      get 'welcome_photo'
      get 'welcome_about'
      get 'welcome_invite'
      get 'welcome_complete'
      
      match 'statistics'
      match 'crop_profile_photo'
      match 'upload_profile_photo'
      match 'metro_area_update'
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
      collection do
        post :swfupload
        get :slideshow
      end
    end

    resources :posts do
      collection do
        get :manage
      end
      match :send_to_friend, :on => :member
      match :update_views, :on => :member
      member do
        get :contest
      end
    end

    resources :events
    resources :clippings
    resources :activities do
      collection do
        get :network
      end
    end

    resources :invitations
    resources :offerings do
      collection do
        put :replace
      end
    end

    resources :favorites
    resources :messages do
      match :auto_complete_for_username, :on => :collection
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
  match '/users/:user_id/posts/category/:category_name' => 'posts#index', :as => :users_posts_in_category

end