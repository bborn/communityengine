class PostPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      if user.admin?
        scope.unscoped
      else
        scope.unscoped.where(:user_id => user.id)
      end
    end
  end

end
