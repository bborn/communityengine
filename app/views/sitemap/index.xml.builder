xml.instruct!
 
xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
  xml.url do
    xml.loc         "#{home_url}"
    xml.lastmod     w3c_date(Time.now)
    xml.changefreq  "hourly"
  end
  
  @users.find_each do |user|
    xml.url do
      xml.loc         "#{home_url}#{user.login_slug}"  
      xml.lastmod     w3c_date(user.updated_at ||  Time.now)
      xml.changefreq  "weekly"
      xml.priority    0.7
    end
  end  

  @posts.find_each do |post|
    xml.url do
      xml.loc         user_post_url post['login_slug'], post.id
      xml.lastmod     w3c_date(post.published_at)
      xml.changefreq  "weekly"
      xml.priority    0.6
    end
  end

end
