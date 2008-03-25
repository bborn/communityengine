xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"

xml.rss "version" => "2.0",
  'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:atom'       => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "#{search_posts_title}"
    xml.link "http://#{request.host_with_port}#{search_all_sb_posts_path}"
    xml.language "en-us"
    xml.ttl "60"
    xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "http://#{request.host_with_port}/open_search.xml"
    unless params[:q].blank?
      xml.tag! "opensearch:totalResults", @post_pages.item_count
      xml.tag! "opensearch:startIndex", (((params[:page] || 1).to_i - 1) * @post_pages.items_per_page)
      xml.tag! "opensearch:itemsPerPage", @post_pages.items_per_page
      xml.tag! "opensearch:Query", :role => 'request', :searchTerms => params[:q], :startPage => (params[:page] || 1)
    end
    render :partial => "layouts/post", :collection => @posts, :locals => {:xm => xml}
  end
end
