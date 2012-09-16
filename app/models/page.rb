class Page < ActiveRecord::Base
  acts_as_publishable :live, :draft, :members_only, :public
  validates_presence_of :title, :body

  attr_accessible :title, :body, :page_public, :published_as

  def to_param
    id.to_s << "-" << (title ? title.parameterize : '')
  end
end
