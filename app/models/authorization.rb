class Authorization < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
  before_destroy :allow_destroy?
  
  def allow_destroy?
    # raise user.authorizations.count.eql?(1).inspect
    errors.add(:base, "You must have at least one authorization provider.") if user.authorizations.count.eql?(1)
    raise ActiveRecord::Rollback    
  end
  
  def self.find_from_hash(hash)    
    find_by_provider_and_uid(hash['provider'], hash['uid'])
  end

  def self.create_from_hash(hash, user = nil)
    user ||= User.create_from_authorization_hash(hash)
    Authorization.create(:user_id => user.id, :uid => hash['uid'], :provider => hash['provider'])
  end
end