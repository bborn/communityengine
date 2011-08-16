class Tagging < ActiveRecord::Base #:nodoc:
  belongs_to :tag, :counter_cache => true
  belongs_to :taggable, :polymorphic => true
  
  def after_destroy
    if Tag.destroy_unused
      if tag.taggings.count.zero?
        tag.destroy
      end
    end
  end
end
