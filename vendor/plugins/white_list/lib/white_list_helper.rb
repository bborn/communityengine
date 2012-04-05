module WhiteListHelper
  
  def self.mattr_accessor_with_default(name, value = nil)
    mattr_accessor name
    self.send("#{name}=", value) if value
  end  
  
  mattr_accessor_with_default :settings, {
      :elements => %w(strong em b i p code pre tt output samp kbd var sub sup dfn cite big small address hr br div span h1 h2 h3 h4 h5 h6 ul ol li dt dd),
      :attributes => { 
        'a'          => %w(href),
        'img'        => %w(src width height alt title), 
        'blockquote' => %w(cite),
        'del'        => %w(cite datetime),
        'ins'        => %w(cite datetime),
        :all         => %w(id class) 
      },
      :protocols  => {
        'a' => {'href' => ['http', 'https', 'mailto', :relative]},
        'img' => {'src'  => ['http', 'https', :relative]}                
      }
    }      

  def white_list(html)
    Sanitize.clean(html, WhiteListHelper.settings)

  end
  
end