require 'test_helper'

class TagTest < ActiveSupport::TestCase
  fixtures :all  

  test "should get popular tags" do
    popular = Tag.popular
    assert_equal popular.first['count'], 2
  end
  
  test "should get related tags" do
    related = tags(:misc).related_tags
    assert_equal(related, [tags(:general)])
  end
  
end
