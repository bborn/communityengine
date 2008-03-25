module ResourceFeeder
  module Rss
    extend self
    
    def render_rss_feed_for(resources, options = {})
      render :text => rss_feed_for(resources, options), :content_type => Mime::RSS
    end
    
    def rss_feed_for(resources, options = {})
      xml = Builder::XmlMarkup.new(:indent => 2)

      options[:feed]       ||= {}
      options[:item]       ||= {}
      options[:url_writer] ||= self
      
      if options[:class] || resources.first
        klass      = options[:class] || resources.first.class
        new_record = klass.new
      else
        options[:feed] = { :title => "Empty", :link => "http://example.com" }
      end
      
      options[:feed][:title]    ||= klass.name.pluralize
      options[:feed][:link]     ||= SimplyHelpful::RecordIdentifier.named_route(new_record, options[:url_writer])
      options[:feed][:language] ||= "en-us"
      options[:feed][:ttl]      ||= "40"
      
      options[:item][:title]       ||= [ :title, :subject, :headline, :name ]
      options[:item][:description] ||= [ :description, :body, :content ]
      options[:item][:pub_date]    ||= [ :updated_at, :updated_on, :created_at, :created_on ]

      resource_link = lambda { |r| SimplyHelpful::RecordIdentifier.named_route(r, options[:url_writer]) }

      xml.instruct!
      xml.rss(:version => "2.0") do
        xml.channel do
          xml.title(options[:feed][:title])
          xml.link(options[:feed][:link])
          xml.description(options[:feed][:description]) if options[:feed][:description]
          xml.language(options[:feed][:language])
          xml.ttl(options[:feed][:ttl])

          for resource in resources
            xml.item do
              xml.title(call_or_read(options[:item][:title], resource))
              xml.description(call_or_read(options[:item][:description], resource))
              xml.pubDate(call_or_read(options[:item][:pub_date], resource).to_s(:rfc822))
              xml.guid(call_or_read(options[:item][:guid] || options[:item][:link] || resource_link, resource))
              xml.link(call_or_read(options[:item][:link] || options[:item][:guid] || resource_link, resource))
            end
          end
        end
      end
    end
    
    private
      def call_or_read(procedure_or_attributes, resource)
        case procedure_or_attributes
          when Array
            attributes = procedure_or_attributes
            resource.send(attributes.select { |a| resource.respond_to?(a) }.first)
          when Symbol
            attribute = procedure_or_attributes
            resource.send(attribute)
          when Proc
            procedure = procedure_or_attributes
            procedure.call(resource)
        end
      end
  end
end