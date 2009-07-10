require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase
  fixtures :messages, :users, :states, :roles
  setup :login_leopoldo, :except => 'test_should_mark_recipient_deleted'
  
  def login_leopoldo
    login_as :leopoldo
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
  
  # TESTING CRUD ACTIONS
  def test_should_get_index_received
    create_message(users(:florian),users(:leopoldo)) 
    get :index, :user_id => users(:leopoldo).id
    assert assigns(:messages)
    assert_response :success
  end

  def test_should_get_index_sent_messages
    create_message(users(:florian),users(:leopoldo)) 
    get :index, :user_id => users(:leopoldo).id, :params => {:mailbox => 'sent'}
    assert_response :success
    assert assigns(:messages)
    assert_equal assigns(:user).unread_message_count, 1
  end
  
  def 
  
  def test_should_get_new
    get :new, :user_id => users(:leopoldo).id
    assert_response :success
    assert assigns(:message)
  end  
  
  def test_should_get_new_reply_to
    create_message(users(:florian),users(:leopoldo))
    m = Message.last
    get :new, :user_id => users(:leopoldo).id, :reply_to => m.id
    assert_response :success
    assert_equal assigns(:message).to, m.sender.login
    assert_equal assigns(:message).subject, "Re: #{m.subject}"
    assert_equal assigns(:message).body, "\n\n*Original message*\n\n #{m.body}"
  end
  
  def test_should_create
    assert_difference Message, :count, +1 do  
      post :create, :message => {:to => users(:florian).login, :body => 'Some content',
        :subject => 'A subject'}, :user_id => users(:leopoldo).id
    end
    assert_redirected_to  user_messages_path(users(:leopoldo))
  end
  
  def test_should_not_create
    assert_no_difference Message, :count do    
      post :create, :message => {:to => users(:leopoldo).login, :body => 'Some content',
        :subject => 'A subject'}, :user_id => users(:leopoldo).id
    end
    assert_response :success
  end
  
  def test_should_get_show
    create_message(users(:florian),users(:leopoldo))
    get :show, :id => Message.last.id, :user_id => users(:leopoldo).id
    assert_equal assigns(:message).body, 'Some content'
    assert_response :success
  end

  def test_read_unread_message
    create_message(users(:florian),users(:leopoldo)) 
    assert_difference users(:leopoldo), :unread_message_count, -1 do  
      get :show, :id => Message.last.id, :user_id => users(:leopoldo).id
    end
  end
  
  def test_should_not_show
    create_message(users(:florian),users(:leopoldo))
    get :show, :id => Message.last.id, :user_id => users(:joe).id
    assert_response 302
  end
  
  def test_should_mark_sender_deleted
    should_mark_deleted(users(:leopoldo))
    assert_equal assigns(:message).sender_deleted, true
  end
  
  def test_should_mark_recipient_deleted
    login_as :florian
    should_mark_deleted(users(:florian))
    assert_equal assigns(:message).recipient_deleted, true
  end
  
  private
  def create_message(sender,recipient)
     Message.create(:sender_id => sender.id, :recipient_id => recipient.id,
        :body => 'Some content', :subject => 'A subject').save!
  end
  
  def should_mark_deleted(user)
    @request.env['HTTP_REFERER'] = "#{user.login}/messages"
    create_message(users(:leopoldo),users(:florian))
    post :delete_selected, :delete => [Message.last.id], :user_id => user.id
    assert_redirected_to "#{user.login}/messages"
  end
  

end