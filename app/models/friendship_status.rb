class FriendshipStatus < ActiveRecord::Base
  acts_as_enumerated

  attr_accessible :name
end
