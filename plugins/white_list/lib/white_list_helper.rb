module WhiteListHelper
  PROTOCOL_ATTRIBUTES = %w(src href)
  PROTOCOL_SEPARATOR  = /:|(&#0*58)|(&#x70)|(%|&#37;)3A/
  mattr_accessor :tags, :attributes, :protocols
  @@tags         = %w(strong em b i p code pre tt output samp kbd var sub sup dfn cite big small address hr br div span h1 h2 h3 h4 h5 h6 ul ol li dt dd)
  @@attributes   = { 
    'a'          => %w(href),
    'img'        => %w(src width height alt), 
    'blockquote' => %w(cite),
    'del'        => %w(cite datetime),
    'ins'        => %w(cite datetime),
    nil          => %w(id class) }
  @@protocols    = %w(ed2k ftp http https irc mailto news gopher nntp telnet webcal xmpp callto feed)
  tags.push(*attributes.keys).uniq!

  def white_listed_tags
    ::WhiteListHelper.tags
  end
  
  def white_listed_attributes
    ::WhiteListHelper.attributes
  end

  def white_listed_protocols
    ::WhiteListHelper.protocols
  end

  def white_list(html, options = {})
    return html if html.blank? || !html.include?('<')
    (options[:attributes] ||= {}).update(white_listed_attributes)
    (options[:tags]       ||= []).push(*options[:attributes].keys).push(*white_listed_tags).uniq!
    returning [] do |new_text|
      tokenizer = HTML::Tokenizer.new(html)
      
      while token = tokenizer.next
        node = HTML::Node.parse(nil, 0, 0, token, false)
        new_text << case node
          when HTML::Tag
            unless (options[:tags]).include?(node.name)
              node.to_s.gsub(/</, "&lt;")
            else
              if node.closing != :close
                attributes = (options[:attributes][nil] || []).push(*(options[:attributes][node.name] || []))
                node.attributes.delete_if do |attr_name, value|
                  !attributes.include?(attr_name) || (PROTOCOL_ATTRIBUTES.include?(attr_name) && contains_bad_protocols?(value))
                end if attributes.any?
              end
              node.to_s
            end
          else
            node.to_s.gsub(/</, "&lt;")
        end
      end
    end.join
  end
  
  private
    def contains_bad_protocols?(value)
      value =~ PROTOCOL_SEPARATOR && !white_listed_protocols.include?(value.split(PROTOCOL_SEPARATOR).first)
    end
end