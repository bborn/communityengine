xml.instruct!
 
xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
  xml.url do
    xml.loc         "#{APP_URL}"
    xml.lastmod     w3c_date(Time.now)
    xml.changefreq  "always"
  end
  
  @users.each do |user|
    xml.url do
      xml.loc         "#{APP_URL}/#{user.login_slug}"  
      xml.lastmod     w3c_date(user.updated_at ||  Time.now)
      xml.changefreq  "weekly"
      xml.priority    0.7
    end
  end  

  @posts.each do |post|
    xml.url do
      xml.loc         "#{APP_URL}/#{post['user_slug']}/posts/#{post.to_param}"
      xml.lastmod     w3c_date(post.published_at)
      xml.changefreq  "daily"
      xml.priority    0.6
    end
  end

end