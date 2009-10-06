class TestPost < ActiveRecord::Base
  belongs_to :test_user
  acts_as_activity :test_user, :if => Proc.new{|record| record.test_user and !record.test_user.login.eql?('elvis') }

end
