module EnginesExtensions

  def require_from_ce(path)
    require_dependency CommunityEngine::Engine.config.root.join('app', path).to_s    
  end
  
end
