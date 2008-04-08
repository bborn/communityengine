module PostsHelper

  def post_with_ad_in_content(post)
    string = Ad.display(:post_content, logged_in?)      

    doc = Hpricot(post.post)
    doc.search("p").each_with_index do |p,i|
      if i.eql?(2)
        p.before string 
        p[:id] = "jump"
      end
    end
    
    doc.to_html
  end


end
