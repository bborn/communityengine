require 'apis/meta_weblog_api'

class MetaWeblogService < ActionWebService::Base
  web_service_api MetaWeblogAPI
  before_invocation :authenticate  

  def newPost(blogid, username, password, struct)
    post = Post.new(:user => @user, :raw_post => struct['description'].to_s, :title => struct['title'].to_s)
    category = Category.find_by_name(struct['categories'][0]) unless struct['categories'].blank?
    post.category = category || nil
    post.save!
    post.id
  end

  def editPost(post_id, username, password, struct)
    post = @user.posts.find(post_id)
    post.update_attributes(:raw_post => struct['description'].to_s, :title => struct['title'].to_s)
    category = Category.find_by_name(struct['categories'][0]) unless struct['categories'].blank?
    post.category = category || nil    
    post.save!
    true
  end
  
  def getPost(post_id, username, password)
    post_dto_from @user.posts.find(post_id)
  end

  def getCategories(blogid, username, password)
    Category.find(:all, :order => 'id ASC').collect{|c| 
      Blog::Category.new( :description => c.name, :id => c.id)
    }
  end

  def getRecentPosts(blogid, username, password, numberOfPosts)
    @user.posts.find(:all, :order => "created_at DESC", :limit => numberOfPosts).collect{ |c| post_dto_from(c) }
  end
  
  def getUsersBlogs(appkey, username, password)
    [Blog::Blog.new(
      :blogid => @user.login_slug,
      :blogName => "#{@user.login}'s Blog",
      :url => "#{APP_URL}/#{@user.login}/posts"
    )]
  end
  
  def newMediaObject(blogid, username, password, data)
    photo = @user.photos.build \
      :filename     => data['name'],
      :content_type => (data['type'] || guess_content_type_from(data['name']))
    # photo.temp_data = Base64.decode64(data['bits'])
    photo.temp_data = data['bits']
    photo.save!
    Blog::Url.new("url" => photo.public_filename(:medium))
  end
  
  def deletePost(key, post_id, user, pw)
    post = @user.posts.find(post_id)
    post.destroy
    true
  end
  
  
  protected 
  
  def post_dto_from(post)
    Blog::Post.new(
    :title => post.title,
    :link => user_post_url(post).to_s,
    :postid => post.id.to_s,    
    :description => post.raw_post,
    :pubDate => post.created_at,
    :dateCreated => post.created_at,    
    :categories => post.category ? [post.category.name] : []
    )
  end  
    
  def user_post_url(post)
    [post.user.to_param, 'posts', post.to_param].join('/')
  end  
  
  def authenticate(name, args)
    method = self.class.web_service_api.api_methods[name]
    # Coping with backwards incompatibility change in AWS releases post 0.6.2
    begin
      h = method.expects_to_hash(args)
      $stderr.puts "h: #{h.inspect} args: #{args.inspect}"      
      raise "Invalid login" unless @user = User.authenticate(h[:username], h[:password])
    rescue NoMethodError
      username, password = method[:expects].index(:username=>String), method[:expects].index(:password=>String)
      raise "Invalid login" unless @user = User.authenticate(args[username], args[password])
    end
  end

  def guess_content_type_from(name)
    if name =~ /(png|gif|jpe?g)/i
      "image/#{$1 == 'jpg' ? 'jpeg' : $1}"
    else
      'application/octet-stream'
    end
  end

end