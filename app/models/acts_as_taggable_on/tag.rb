#require_dependency ActsAsTaggableOn::Engine.config.root.join('app', 'models', 'acts_as_taggable_on', 'tag.rb').to_s

class ActsAsTaggableOn::Tag < ActiveRecord::Base

  class << self
    def popular(limit = 20, type = nil)
      tags = ActsAsTaggableOn::Tag.most_used(limit)
      tags = tags.where("taggings.taggable_type = ?", type.capitalize) if type
      tags
    end

    def default_per_page
      25
    end

  end

  def to_param
    URI.escape(URI.escape(self.name), /[\/.?#]/)
  end

end

