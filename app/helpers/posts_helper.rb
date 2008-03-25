module PostsHelper

  def post_with_ad_in_content(post)
    string = ''
    doc = Hpricot(post.post)
    paragraphs = (doc/"p")
    if paragraphs.size > 4
      paragraphs.each_with_index do |p,i|
        show_ad = i.eql?(2)
        string += Ad.display(:post_content, logged_in?) if show_ad
        p[:id] = "jump" if show_ad        
        string += p.to_s
      end
    else
      string += post.post
    end
    
    string
  end


end
