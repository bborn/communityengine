class Monitorship < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  validates_presence_of :user, :topic
end
