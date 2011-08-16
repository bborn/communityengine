module Viewable
  protected
  def update_view_count(viewable)     
    stack_name = viewable.class.to_s.underscore.downcase
    already_viewed = (cookies[stack_name] || '').split(',') 

    unless already_viewed.include?(viewable.id.to_s)
      cookies[stack_name] = (already_viewed << viewable.id.to_s).join(',')
      viewable.class.update_counters(viewable.id, {:view_count => 1}) 
    end
  end
end
