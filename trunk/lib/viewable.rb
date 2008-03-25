module Viewable
  protected
  def update_view_count(viewable)
    stack_name = Inflector.underscore(viewable.class).downcase
     unless (!session[stack_name].nil? && session[stack_name].include?(viewable.id))
        viewable.update_attribute(:view_count, viewable.view_count + 1)
        if session[stack_name].nil?
           session[stack_name] = [viewable.id]
        else
           session[stack_name].push(viewable.id)
        end
     end
  end
end