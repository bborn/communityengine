module Viewable
  protected
  def update_view_count(viewable)  
    stack_name = Inflector.underscore(viewable.class).downcase
    
    if session[stack_name].nil?
      session[stack_name] = [viewable.id]      
      viewable.update_attribute(:view_count, viewable.view_count + 1)      
    elsif !session[stack_name].include?(viewable.id)
      session[stack_name] << viewable.id
      viewable.update_attribute(:view_count, viewable.view_count + 1)
    else
      #already viewed it, do nothing
      return false
    end
  end
end