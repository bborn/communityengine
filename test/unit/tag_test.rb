require 'test_helper'

class TagTest < ActiveSupport::TestCase
  fixtures :all  

  test "should get popular tags" do
    popular = Tag.popular
    assert_equal popular.first['count'], 2
  end
  
  test "should get popular tags of one type" do
    popular = Tag.popular(20, 'clipping')
    assert_equal popular.to_a.size, 1
    assert_equal popular.first['count'], 2
  end
  
  test "should get related tags" do
    related = tags(:misc).related_tags
    assert_equal(related, [tags(:general)])
  end
  
end
