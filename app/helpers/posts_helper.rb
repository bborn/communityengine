module PostsHelper

  def post_with_ad_in_content(post)
    string = Ad.display(:post_content, logged_in?)      

    doc = Hpricot(post.post)
    paragraphs = doc.search("p")
    
    if paragraphs.length > 4
      paragraphs.each_with_index do |p,i|
        if i.eql?(2)
          p.before string 
          p[:id] = "jump"
        end
      end
    end
    
    doc.to_html
  end


end
