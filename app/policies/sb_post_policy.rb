class SbPostPolicy < ApplicationPolicy

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
