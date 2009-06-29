xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.rss "version" => "2.0",
  'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:atom'       => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Posts that #{@user.display_name} is monitoring | Beast"
    xml.link monitored_sb_user_posts_url(@user)
    xml.language "en-us"
    xml.ttl "60"
    xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "http://#{request.host_with_port}/open_search.xml"

    render :partial => "layouts/post", :collection => @posts, :locals => {:xm => xml}
  end
end
