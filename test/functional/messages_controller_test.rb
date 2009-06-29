require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase
  fixtures :users, :messages
  setup :login_leopoldo, :except => 'test_should_mark_recipient_deleted'
  
  def login_leopoldo
    login_as :leopoldo
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