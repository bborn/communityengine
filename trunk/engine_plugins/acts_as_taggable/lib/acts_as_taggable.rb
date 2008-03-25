module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)  
      end
      
      module ClassMethods
        def acts_as_taggable(options = {})
          write_inheritable_attribute(:acts_as_taggable_options, {
            :taggable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
            :from => options[:from]
          })
          
          class_inheritable_reader :acts_as_taggable_options

          has_many :taggings, :as => :taggable, :dependent => :destroy
          has_many :tags, :through => :taggings

          include ActiveRecord::Acts::Taggable::InstanceMethods
          extend ActiveRecord::Acts::Taggable::SingletonMethods          
        end
      end
      
      module SingletonMethods
        def find_tagged_with(list, options = {})
          query = "SELECT #{table_name}.* FROM #{table_name}, tags, taggings "
          query << "WHERE #{table_name}.#{primary_key} = taggings.taggable_id "
          query << "AND taggings.taggable_type = ? "
          query << "AND taggings.tag_id = tags.id AND tags.name IN (?)"
          query << options[:sql] unless options[:sql].nil?
          query << " ORDER BY #{options[:order]}" unless options[:order].nil?
          query << " LIMIT #{options[:limit]}" unless options[:limit].nil?
          find_by_sql([query, acts_as_taggable_options[:taggable_type], list
          ])
        end
        
        def tags_count(options = {})
          query = "SELECT tags.id, tags.name, count(*) AS count "
          if options[:user_id]  
            query << " FROM #{table_name}, taggings, tags"
            query << " WHERE #{table_name}.user_id = '#{options[:user_id]}'"
            query << " AND taggings.taggable_id = #{table_name}.id"
            query << " AND tags.id = taggings.tag_id"  
          else
            query << " FROM taggings, tags"
            query << " WHERE tags.id = taggings.tag_id"
          end
          query << " AND taggings.taggable_type = '#{acts_as_taggable_options[:taggable_type]}'"
          query << options[:sql] unless options[:sql].nil?
          query << " GROUP BY tag_id"
          query << " ORDER_BY #{options[:order]}" if options[:order] != nil
          query << " LIMIT   #{options[:limit]}" if options[:limit] != nil
          tags = Tag.find_by_sql(query)          
        end    
        
      end
      
      module InstanceMethods
        def tag_with(list)
          Tag.transaction do
            taggings.destroy_all

            Tag.parse(list).each do |name|
              if acts_as_taggable_options[:from]
                send(acts_as_taggable_options[:from]).tags.find_or_create_by_name(name).on(self)
              else
                Tag.find_or_create_by_name(name).on(self)
              end
            end
          end
        end

        def tag_list
          tags.collect { |tag| tag.name.include?(" ") ? "'#{tag.name}'" : tag.name }.join(" ")
        end
        
      end
    end
  end
end