require File.dirname(__FILE__) + '/../test_helper'

class MessageTest < ActiveSupport::TestCase
  fixtures :all

  def test_should_send_notification
    assert_difference ActionMailer::Base.deliveries, :length, 1 do
      message = Message.create!(:sender => users(:quentin), :recipient => users(:aaron), :body => 'hey aaron', :subject => 'Hello friend!')
    end
  end
  
  def test_should_be_invalid_without_subject
    m = Message.new(:subject => nil)
    assert !m.valid?
    assert m.errors.on(:subject)
  end

  def test_should_be_invalid_without_body
    m = Message.new(:body => nil)
    assert !m.valid?
    assert m.errors.on(:body)
  end
  
  def test_should_be_invalid_without_recipient
    m = Message.new(:recipient => nil)
    assert !m.valid?
    assert m.errors.on(:recipient)
  end
  
  def test_should_not_allow_message_to_self
    m = Message.new(:sender => users(:quentin), :recipient => users(:quentin))
    assert !m.valid?
    assert m.errors.on(:base)
  end
  
  def test_should_be_deleted_with_user
    message = Message.create!(:sender => users(:quentin), :recipient => users(:aaron), :body => 'hey aaron', :subject => 'Hello friend!')    
  
    assert_difference Message, :count, -1 do
      users(:quentin).destroy
    end
  end


end
