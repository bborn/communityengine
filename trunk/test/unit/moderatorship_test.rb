require File.dirname(__FILE__) + '/../test_helper'

class ModeratorshipTest < Test::Unit::TestCase
  all_fixtures

  def test_should_find_moderators
    assert_models_equal [users(:sam)], forums(:rails).moderators
  end
  
  def test_should_find_moderated_forums
    assert_models_equal [forums(:rails)], users(:sam).forums
  end
  
  def test_should_add_moderator
    assert_equal [], forums(:comics).moderators
    assert_difference Moderatorship, :count do
      forums(:comics).moderators << users(:sam)
    end
    assert_models_equal [users(:sam)], forums(:comics).moderators(true)
  end
  
  def test_should_not_add_duplicate_moderator
    assert_models_equal [users(:sam)], forums(:rails).moderators
    assert_difference Moderatorship, :count, 0 do
      assert_raise ActiveRecord::RecordNotSaved do 
        forums(:rails).moderators << users(:sam)
      end
    end
  end
end
