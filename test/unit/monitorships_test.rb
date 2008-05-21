require File.dirname(__FILE__) + '/../test_helper'

class MonitorshipsTest < Test::Unit::TestCase
  all_fixtures

  def test_should_find_monitorships_from_users
    assert_models_equal [monitorships(:aaron_pdi)], users(:aaron).monitorships
    assert_models_equal [monitorships(:sam_pdi)],   users(:sam).monitorships
  end
  
  def test_should_find_monitorships_from_topics
    assert_models_equal [monitorships(:aaron_pdi), monitorships(:sam_pdi)], topics(:pdi).monitorships
  end
  
  def test_should_find_active_watchers
    assert_models_equal [users(:aaron)], topics(:pdi).monitors
  end

  def test_should_find_monitored_topics_for_user
    assert_models_equal [topics(:pdi)], users(:aaron).monitored_topics
  end
  
  def test_should_not_find_inactive_monitored_topics
    assert_equal [], users(:sam).monitored_topics
  end
  
  def test_should_not_find_any_monitored_topics
    assert_equal [], users(:joe).monitored_topics
  end
  
  def test_should_be_deleted_when_user_destroyed
    m = monitorships(:aaron_pdi)
    id = m.id
    m.user.destroy
    assert !Monitorship.exists?(id)
  end  
  
end
