class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :item, :polymorphic => true
  validates_presence_of :user_id

  after_save :update_counter_on_user

  scope :of_item_type, lambda {|type|
    where("activities.item_type = ?", type)
  }
  scope :since, lambda { |time|
    where("activities.created_at > ?", time)
  }
  scope :before, lambda {|time|
    where("activities.created_at < ?", time)
  }
  scope :recent, lambda { order("activities.created_at DESC") }
  scope :by_users, lambda {|user_ids|
    where('activities.user_id in (?)', user_ids)
  }


  def update_counter_on_user
    if user && user.class.column_names.include?('activities_count')
      new_count =  Activity.by(user)
      user.update_attribute(:activities_count, new_count )
    end
  end

  def self.by(user)
    Activity.where("user_id = ?", user.id).count
  end

  def can_be_deleted_by?(user)
    return false if user.nil?
    return false unless user.admin? || user.moderator? || self.user_id.eql?(user.id)
    true
  end

end
