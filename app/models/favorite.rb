class Favorite < ActiveRecord::Base
  acts_as_activity :user
  belongs_to :favoritable, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :favoritable
  
  validates_presence_of :ip_address
  
  after_save :update_counter_on_favoritable
  after_destroy :update_counter_on_favoritable
  
  validates_uniqueness_of :user_id, :scope => [:favoritable_type, :favoritable_id], :allow_nil => true, :message => 'has already favorited this item.'
  validates_uniqueness_of :ip_address, :scope => [:favoritable_type, :favoritable_id], :message => 'has already favorited this item.', :if => Proc.new{|f| f.user.nil? }
  
  def update_counter_on_favoritable
    if favoritable && favoritable.respond_to?(:favorited_count)
      favoritable.update_attribute(:favorited_count, favoritable.favorites.count.to_s )
    end
  end
  
  def self.find_favorites_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end
  
  def self.find_by_user_or_ip_address(favoritable = nil, user = nil, remote_ip = nil)
    return false unless favoritable && (user || remote_ip)
    
    if user
      favorite = self.find(:first, :conditions => ["user_id = ? AND favoritable_type = ? AND favoritable_id = ?", user.id, favoritable.class.to_s, favoritable.id])
    else
      favorite = self.find(:first, :conditions => ["ip_address = ? AND favoritable_type = ? AND favoritable_id = ?", remote_ip, favoritable.class.to_s, favoritable.id])      
    end
    return favorite
  end

end