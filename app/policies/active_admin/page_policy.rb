class ActiveAdmin::PagePolicy < ApplicationPolicy

  def dashboard?
   true
  end

  def index?
   true
  end

end
