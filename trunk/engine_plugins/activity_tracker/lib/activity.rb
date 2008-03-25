class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :item, :polymorphic => true
  validates_presence_of :user_id
  
  after_save :update_counter_on_user
  
  def update_counter_on_user
    if user && user.class.column_names.include?('activities_count')
      user.update_attribute(:activities_count, Activity.by(user) )
    end
  end
  
  def self.by(user)
    Activity.count(:all, :conditions => ["user_id = ?", user.id])
  end
    
end
