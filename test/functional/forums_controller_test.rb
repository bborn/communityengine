require File.dirname(__FILE__) + '/../test_helper'

class ForumsControllerTest < ActionController::TestCase
  all_fixtures

  def setup
    @controller = ForumsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:forums)
  end

  def test_should_get_index_with_xml
    content_type 'application/xml'
    get :index, :format => 'xml'
    assert_response :success
  end

  def test_should_get_new
    login_as :admin
    get :new
    assert_response :success
  end
  
  def test_should_require_admin
    login_as :sam
    get :new
    assert_redirected_to login_path
  end
  
  def test_should_create_forum
    login_as :admin
    assert_difference Forum, :count, 1 do
      post :create, :forum => { :name => 'yeah' }, :tag_list => 'tag1 tag2'

      forum = Forum.find_by_name('yeah')
      assert_equal ['tag1', 'tag2'], forum.tag_list
    end
    
    assert_redirected_to forums_path
  end
  
  def test_should_show_forum
    get :show, :id => 1
    assert_response :success
    assert assigns(:topics)
    # sticky should be first
    assert_equal(topics(:sticky), assigns(:topics).first)
  end
  
  def test_should_show_forum_with_xml
    content_type 'application/xml'
    get :show, :id => 1, :format => 'xml'
    assert_response :success
    assert_select 'forum'
  end

  def test_should_get_edit
    login_as :admin
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_forum
    login_as :admin
    put :update, :id => 1, :forum => { }, :tag_list => 'tagX tagY'
    assert_redirected_to forums_path

    assert_equal ['tagX', 'tagY'], Forum.find(1).tag_list
  end

  # def test_should_update_forum_with_xml
  #   authorize_as :aaron
  #   content_type 'application/xml'
  #   put :update, :id => 1, :forum => { }, :format => 'xml'
  #   assert_response :success
  # end

  def test_should_destroy_forum
    login_as :admin
    old_count = Forum.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Forum.count
    
    assert_redirected_to forums_path
  end

  # def test_should_destroy_forum_with_xml
  #   authorize_as :aaron
  #   content_type 'application/xml'
  #   old_count = Forum.count
  #   delete :destroy, :id => 1, :format => 'xml'
  #   assert_equal old_count-1, Forum.count
  #   assert_response :success
  # end
end
