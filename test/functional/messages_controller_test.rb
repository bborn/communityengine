require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase
  fixtures :messages, :users, :states, :roles
  setup :login_leopoldo, :except => 'test_should_mark_recipient_deleted'
  
  def login_leopoldo
    login_as :leopoldo
  end
   
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
  
  def test_should_only_show_your_messages
    get :index, :user_id => users(:aaron).id
    assert_redirected_to login_path
  end
  
  def test_should_get_new
    get :new, :user_id => users(:leopoldo).id
    assert_response :success
    assert assigns(:message)
  end
  
  def test_send_message_link_should_populate_to_field
    get :new, :user_id => users(:leopoldo).id, :to => 'aaron'
    assert_response :success
    assert_tag :tag=>'input', :attributes=>{:value=>'aaron'}
    assert assigns(:message)
  end  
  
  def test_should_get_new_reply_to_and_populate_all_fields
    create_message(users(:florian),users(:leopoldo))
    m = Message.last
    get :new, :user_id => users(:leopoldo).id, :reply_to => m.id
    assert_response :success
    assert_equal assigns(:message).to, m.sender.login
    assert_tag :tag=>'input', :attributes=>{:name=>'message[to]', :value=> m.sender.login}
    assert_equal assigns(:message).subject, "#{m.subject}"
  end
  
  def test_should_create
    assert_difference Message, :count, 1 do  
      post :create, :message => {:to => users(:florian).login, :body => 'Some content',
        :subject => 'A subject'}, :user_id => users(:leopoldo).id
    end
    assert_redirected_to  user_messages_path(users(:leopoldo))
  end
  
  
  def test_should_not_create_same_user_message
    assert_no_difference Message, :count do    
      post :create, :message => {:to => users(:leopoldo).login, :body => 'Some content',
        :subject => 'A subject'}, :user_id => users(:leopoldo).id
    end
    assert_response :success
  end
    
  def test_should_fail_to_create_message_with_no_to
    assert_no_difference Message, :count do
      post :create, :user_id => users(:leopoldo).id, :message => { :subject => 'Test message', :body => 'Test message' }
    end
    assert_response :success
  end
  
  def test_should_fail_to_create_message_with_invalid_to
    assert_no_difference Message, :count do
      post :create, :user_id => users(:leopoldo).id, :message => { :to => 'notarealuser', :subject => 'Test message', :body => 'Test message' }
    end
    assert_response :success
  end
  
  def test_should_destroy_message
    assert_difference Message, :count, -1 do
      post :delete_selected, :delete => [2], :user_id => users(:leopoldo).id
    end
    assert_redirected_to user_messages_path(users(:leopoldo))
  end
  
  
  def test_should_get_show
    create_message(users(:florian),users(:leopoldo))
    get :show, :id => Message.last.id, :user_id => users(:leopoldo).id
    assert_response :success
    assert_equal assigns(:message).body, 'Some content'
    assert_tag :tag=>'a', :attributes=>{:href=>"/leopoldo/messages/new?reply_to=#{Message.last.id}"}
  end
  
  def test_show_send_links_if_logged_in
    @controller = UsersController.new
    get :show, :user_id => users(:aaron).id
    assert_response :success
  end
  
  

  def test_read_unread_message
    create_message(users(:florian),users(:leopoldo)) 
    assert_difference users(:leopoldo), :unread_message_count, -1 do  
      get :show, :id => Message.last.id, :user_id => users(:leopoldo).id
    end
  end
  
  def test_should_not_show_other_user_message
    create_message(users(:florian),users(:leopoldo))
    get :show, :id => Message.last.id, :user_id => users(:joe).id
    assert_response 302
  end

  def test_do_not_show_send_links
    get :show, :user_id => users(:aaron).id
    assert_redirected_to '/login'
    assert_no_tag :tag=>'a', :attributes=>{:href=>'/quentin/messages/new?to=aaron'}
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