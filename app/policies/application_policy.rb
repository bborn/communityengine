class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    true
  end

  def index?
    true
  end

  def new?
    create?
  end

  def create?
    true
  end

  def edit?
    update?
  end

  def update?
    user.admin? || record.respond_to(:user) && record.user.eql?(user)
  end

  def destroy?
    update?
  end

  def destroy_all?
    user.admin?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

end

