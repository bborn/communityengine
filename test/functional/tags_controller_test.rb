require File.dirname(__FILE__) + '/../test_helper'

class TagsControllerTest < Test::Unit::TestCase
  fixtures :tags, :taggings, :photos, :roles, :posts

  def setup
    @controller = TagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_autocomplete_tags
    get :auto_complete_for_tag_name, :id => 'mis', :format => 'js'
    assert_response :success
  end


  def test_should_show_tag
   get :show, :id => tags(:general).name
   assert_response :success
   assert assigns(:photos).include?(photos(:library_pic))
  end

  def test_should_fail_to_show_tag
   get :show, :id => 'tag_that_does_not_exist'
   assert_redirected_to :action => :index
  end

  def test_should_get_index
   get :index
   assert_response :success
  end
  
  def test_should_show_matching_items_for_multiple_tags
    posts(:apt_post).tag_list = tags(:general).name + ',' + tags(:extra).name
    posts(:apt_post).save
    posts(:apt2_post).tag_list = tags(:general).name + ',' + tags(:extra).name + ',' + tags(:misc).name
    posts(:apt2_post).save

    get :show, :id => 'general extra'
    assert_response :success
    assert_equal 2, assigns(:posts).size
    assert assigns(:posts).include?(posts(:apt_post))
    assert assigns(:posts).include?(posts(:apt2_post))
  end
end
