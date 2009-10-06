require File.dirname(__FILE__) + '/../test_helper'

class MonitorshipsControllerTest < ActionController::TestCase

  all_fixtures

  def test_should_require_login
    post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:aaron).id
    assert_redirected_to login_path
  end
  
  def test_should_add_monitorship
    login_as :joe
    assert_difference Monitorship, :count do 
      xhr :post, :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:joe).id
      assert_response :success
    end
    
    assert topics(:pdi).monitors.include?(users(:joe))
  end
  
  def test_should_activate_monitorship
    login_as :sam
    assert_difference Monitorship, :count, 0 do
      xhr :post, :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:sam).id      
      assert_response :success
    end
  end
  
  def test_should_not_duplicate_monitorship
    login_as :aaron
    assert_difference Monitorship, :count, 0 do
      xhr :post, :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:aaron).id
      assert_response :success
    end
  end
  
  def test_should_deactivate_monitorship
    login_as :aaron
    assert_difference Monitorship, :count, 0 do
      xhr :delete, :destroy, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:aaron).id
      assert_response :success
    end

    assert !topics(:pdi).monitors(true).include?(users(:aaron))
  end

  def test_should_require_login_with_html
    post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:aaron).id
    assert_redirected_to login_path
  end
  
  def test_should_add_monitorship_with_html
    login_as :joe
    assert_difference Monitorship, :count do 
      post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:joe).id
      assert_redirected_to forum_topic_path(forums(:rails).id, topics(:pdi).id)
    end
    
    assert topics(:pdi).monitors(true).include?(users(:joe))
  end
  
  def test_should_deactivate_monitorship_with_html
    login_as :aaron
    assert_difference Monitorship, :count, 0 do
      delete :destroy, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:aaron).id
      assert_redirected_to forum_topic_path(forums(:rails).id, topics(:pdi).id)
    end

    assert !topics(:pdi).monitors(true).include?(users(:aaron))
  end
end
