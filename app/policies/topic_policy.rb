class TopicPolicy < ApplicationPolicy

  def new?
    create?
  end

  def create?
    true
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  def update?
    record.editable_by?(user)
  end

end
