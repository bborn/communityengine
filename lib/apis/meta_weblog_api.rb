module Blog
  class Blog < ActionWebService::Struct
    member :blogid,       :string
    member :blogName,     :string
    member :url,          :string    
  end

  class Post < ActionWebService::Struct
    member :title,       :string
    member :link,        :string
    member :postid,      :string    
    member :description, :string
    member :author,      :string
    member :categories,  [:string]
    member :comments,    :string
    member :guid,        :string
    member :pubDate,     :string
    member :dateCreated,  :time    
  end

  class Category < ActionWebService::Struct
    member :description, :string
    member :id, :string
  end
  
  class MediaObject < ActionWebService::Struct
    member :bits, :string
    member :name, :string
    member :type, :string
  end  
  
  class Url < ActionWebService::Struct
    member :url, :string
  end
  
end

class MetaWeblogAPI < ActionWebService::API::Base
  inflect_names false

  api_method :newPost, :returns => [:string], :expects => [
    {:blogid=>:string},
    {:username=>:string},
    {:password=>:string},
    {:struct=>Blog::Post}
  ]

  api_method :editPost, :returns => [:bool], :expects => [
    {:post_id=>:string},
    {:username=>:string},
    {:password=>:string},
    {:struct=>Blog::Post}
  ]

  api_method :deletePost, :returns => [:bool], :expects => [
    {:appkey=>:string},
    {:postid=>:string},
    {:username=>:string},
    {:password=>:string}    
    ]
    
  api_method :getPost, :returns => [Blog::Post], :expects => [
    {:post_id=>:string},
    {:username=>:string},
    {:password=>:string}
  ]

  api_method :getCategories, :returns => [[Blog::Category]], :expects => [
    {:blogid=>:string},
    {:username=>:string},
    {:password=>:string}
  ]

  api_method :getRecentPosts, :returns => [[Blog::Post]], :expects => [
    {:blogid=>:string},
    {:username=>:string},
    {:password=>:string},
    {:numberOfPosts=>:int}
  ]
    
  api_method :newMediaObject,
    :expects => [ {:blogid => :string}, {:username => :string}, {:password => :string}, {:data => Blog::MediaObject} ],
    :returns => [Blog::Url]
    
    
  api_method :getUsersBlogs, :returns => [[Blog::Blog]], :expects => [
    {:blogid=>:string},
    {:username=>:string},
    {:password=>:string}
  ]
end