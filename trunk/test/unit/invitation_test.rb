require File.dirname(__FILE__) + '/../test_helper'

class InvitationTest < Test::Unit::TestCase
  fixtures :invitations, :users

  def test_email_addresses_validation
    addresses = "valid@example.com, valid_2@example.com, invalid.invalid.com"
    invitation = Invitation.new(:email_addresses => addresses)
    assert !invitation.valid?
    assert invitation.errors.on(:email_addresses)
  end
  
  def test_send_with_names_in_emails
    addresses = '"Valid Example" <valid@example.com>, valid_2@example.com'
    invitation = Invitation.new(:email_addresses => addresses, :user => users(:quentin))
    assert invitation.valid?
    assert invitation.send_invite    
  end
  
  def test_send_invite
    addresses = "valid@example.com, valid_2@example.com"
    invitation = Invitation.new(:email_addresses => addresses, :user => users(:quentin))
    assert invitation.valid?
    assert invitation.send_invite
  end

end
