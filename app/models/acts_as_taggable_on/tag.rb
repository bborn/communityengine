# require_dependency ActsAsTaggableOn::Engine.config.root.join('lib', 'acts_as_taggable_on', 'tag.rb').to_s

class ActsAsTaggableOn::Tag < ActiveRecord::Base

  class << self
    def popular(limit = 20, type = nil)
      tags = ActsAsTaggableOn::Tag.most_used(limit)
      tags
    end

    def default_per_page
      25
    end

  end

  def to_param
    URI.escape(URI.escape(self.name), /[\/.?#]/)
  end


  def related_tags(limit = 10)
    taggables = self.taggings.limit(10).to_a.collect{|t| t.taggable }.compact

    tagging_ids = taggables.map{|t| t.taggings.limit(10).map(&:id) }.flatten.uniq
    return [] if tagging_ids.blank?

    ActsAsTaggableOn::Tag.where("tags.id != '#{self.id}'")
      .joins(:taggings)
      .where({:taggings => {:id => tagging_ids }})
      .order("taggings_count DESC")
      .limit(limit)
  end

end

