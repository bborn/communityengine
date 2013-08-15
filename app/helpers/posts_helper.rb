module PostsHelper

  # The ShareThis widget defines a bunch of attributes you can customize.
  # Facebook seems to ignore them (it uses title and description meta tags
  # instead).  MySpace, however, only works if you set these attributes.
  def sharethis_options(post)
    content_tag :script, :type=>"text/javascript" do
        "SHARETHIS.addEntry({
          title:'#{escape_javascript(post.title)}',
          content:'#{escape_javascript(truncate_words(post.post, 75, '...' ))}'
        }, {button:true});".html_safe
    end
  end

end
