class StaticPage < ActiveRecord::Base
  validates_presence_of :url, :visibility
  validates_uniqueness_of :url
end
