class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :item, :polymorphic => true
  validates_presence_of :user_id
  
  after_save :update_counter_on_user
  
  named_scope :of_item_type, lambda {|type|
    {:conditions => ["activities.item_type = ?", type]}
  }
  named_scope :since, lambda { |time|
    {:conditions => ["activities.created_at > ?", time] }
  }
  named_scope :recent, :order => "activities.created_at DESC"
  named_scope :by_users, lambda {|user_ids|
    {:conditions => ['activities.user_id in (?)', user_ids]}
  }
  
  
  def update_counter_on_user
    if user && user.class.column_names.include?('activities_count')
      user.update_attribute(:activities_count, Activity.by(user) )
    end
  end
  
  def self.by(user)
    Activity.count(:all, :conditions => ["user_id = ?", user.id])
  end
    
end
