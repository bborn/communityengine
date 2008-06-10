require File.dirname(__FILE__) + '/../test_helper'
require 'tags_controller'

# Re-raise errors caught by the controller.
class TagsController; def rescue_action(e) raise e end; end

class TagsControllerTest < Test::Unit::TestCase
  fixtures :tags, :taggings, :photos, :roles

  def setup
    @controller = TagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
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
  
  
end
