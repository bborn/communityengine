require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase
  fixtures :messages, :users, :states, :roles

  def setup
    @controller = MessagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_do_not_show_send_links_if_not_logged_in
    @controller = UsersController.new
    get :show, :user_id => users(:aaron).id
    assert_response :success
    assert_no_tag :tag=>'a', :attributes=>{:href=>'/quentin/messages/new?to=aaron'}
  end

  def test_show_send_links_if_logged_in
    @controller = UsersController.new
    login_as :quentin
    get :show, :user_id => users(:aaron).id
    assert_response :success
    assert_tag :tag=>'a', :attributes=>{:href=>'/quentin/messages/new?to=aaron'}
  end

  def test_send_message_link_should_populate_to_field
    login_as :quentin
    get :new, :user_id => users(:quentin).id, :to => 'aaron'
    assert_response :success
    assert_tag :tag=>'input', :attributes=>{:value=>'aaron'}
  end

  def test_reply_should_populate_all_fields
    login_as :kevin
    get :new, :user_id => users(:kevin).id, :reply_to => 2
    assert_response :success
    assert_tag :tag=>'input', :attributes=>{:name=>'message[to]', :value=>'aaron'}
    assert_tag :tag=>'textarea', :attributes=>{:name=>'message[body]'}, :content => '&#x000A;&#x000A;*Original message*&#x000A;&#x000A; Test body'
  end

  def test_should_get_index
    login_as :quentin
    get :index, :user_id => users(:quentin).id
    assert_response :success
    assert assigns(:messages)
  end

  def test_should_get_new
    login_as :quentin
    get :new, :user_id => users(:quentin).id
    assert_response :success
  end

  def test_should_only_show_your_messages
    login_as :quentin
    get :index, :user_id => users(:aaron).id
    assert_redirected_to login_path
  end

  def test_should_create_message
    login_as :kevin
    assert_difference Message, :count, 1 do
      post :create, :user_id => users(:kevin).id, :message => {:to => 'aaron', :subject => 'Test message', :body => 'Test message' } 
    end
    assert_redirected_to user_messages_path(users(:kevin))
  end

  def test_should_create_multiple_messages
    login_as :kevin
    assert_difference Message, :count, 2 do
      post :create, :user_id => users(:kevin).id, :message => {:to => 'aaron,leopoldo', :subject => 'Test message', :body => 'Test message' } 
    end
    assert_redirected_to user_messages_path(users(:kevin))
  end

  def test_should_fail_to_create_message_with_no_to
    login_as :kevin
    assert_no_difference Message, :count do
      post :create, :user_id => users(:kevin).id, :message => { :subject => 'Test message', :body => 'Test message' }
    end
    assert_response :success
  end

  def test_should_fail_to_create_message_with_invalid_to
    login_as :quentin
    assert_no_difference Message, :count do
      post :create, :user_id => users(:quentin).id, :message => { :to => 'aaron,notarealuser', :subject => 'Test message', :body => 'Test message' }
    end
    assert_response :success
  end

  def test_should_destroy_message
    login_as :aaron
    assert_difference Message, :count, -1 do
      post :delete_selected, :delete => [2], :user_id => users(:aaron).id
    end
    assert_redirected_to user_messages_path(users(:aaron))
  end

end
