require 'test_helper'

class ModeratorshipTest < ActiveSupport::TestCase
  fixtures :all

  def test_should_find_moderators
    assert_equal [users(:sam)], forums(:rails).moderators
  end
  
  def test_should_find_moderated_forums
    assert_equal [forums(:rails)], users(:sam).forums
  end
  
  def test_should_add_moderator
    assert_equal [], forums(:comics).moderators
    assert_difference Moderatorship, :count, 1 do
      forums(:comics).moderators << users(:sam)
    end
    assert_equal [users(:sam)], forums(:comics).moderators(true)
  end
  
  def test_should_not_add_duplicate_moderator
    assert_equal [users(:sam)], forums(:rails).moderators
    assert_difference Moderatorship, :count, 0 do
      assert_raise ActiveRecord::RecordInvalid do 
        forums(:rails).moderators << users(:sam)
      end
    end
  end
end
