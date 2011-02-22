class Authorization < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
  before_destroy :allow_destroy?

  def self.find_or_create_from_hash(hash, existing_user = nil)
    if (auth = find_from_hash(hash))
      auth.assign_account_info(hash)
      auth.save!
      auth
    else
      create_from_hash(hash, existing_user)
    end
  end
  
  def self.create_from_hash(hash, existing_user = nil)
    create! do |authorization|
      authorization.assign_account_info(hash)
      authorization.find_or_create_user(existing_user)
    end    
  end
  
  def self.find_from_hash(hash)    
    find_by_provider_and_uid(hash['provider'], hash['uid'])
  end

  def find_or_create_user(existing_user = nil)
    if existing_user
      self.user = existing_user
    elsif self.user 
      self.user
    else
      self.user = User.create_from_authorization(self)      
    end
  end
  
  
  def allow_destroy?
    if user.authorizations.count.eql?(1)    
      errors.add(:base, "You must have at least one authorization provider.") 
      raise ActiveRecord::Rollback    
    end
  end
  
  def assign_account_info(auth_hash)
    self.uid                 = auth_hash['uid']
    self.provider            = auth_hash['provider']
    self.nickname            = auth_hash['user_info']['nickname']
    self.email               = auth_hash['user_info']['email']    
    self.picture_url         = auth_hash['user_info']['image']
    self.name                = auth_hash['user_info']['name']
    if auth_hash['credentials']
      self.access_token        = auth_hash['credentials']['token']
      self.access_token_secret = auth_hash['credentials']['secret']
    end
  end
  

end