class Forum < ActiveRecord::Base
  acts_as_taggable
  acts_as_list

  validates_presence_of :name

  has_many :moderatorships, :dependent => :destroy
  has_many :moderators, :through => :moderatorships, :source => :user

  has_many :topics, :dependent => :destroy

  has_many :sb_posts

  belongs_to :owner, :polymorphic => true

  format_attribute :description

  attr_accessible :name, :position, :description
  
  def to_param
    id.to_s << "-" << (name ? name.parameterize : '' )
  end
  
end
