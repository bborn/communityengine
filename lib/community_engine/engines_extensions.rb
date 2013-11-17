module EnginesExtensions

  def require_from_ce(path)
    require_dependency CommunityEngine::Engine.config.root.join('app', path).to_s
  end

  def acts_as_moderated_commentable
    acts_as_commentable :published, :pending
    has_many :comments, {
      :as => :commentable,
      :dependent => :destroy,
      :conditions => "role != 'pending'",
      :before_add => Proc.new { |x, c| c.role = 'published' }
    }
    attr_protected :role
  end


end
