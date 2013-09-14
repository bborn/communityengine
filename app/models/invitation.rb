class Invitation < ActiveRecord::Base
  acts_as_activity :user
  
  belongs_to :user
  
  after_save :send_invite

  validates_presence_of :user
  validates_presence_of :email_addresses
  validates_length_of :email_addresses, :minimum => 6
  validates_length_of :email_addresses, :maximum => 1500

  validates_each :email_addresses do |record, attr, email_addresses |
    invalid_emails = []
    email_addresses = email_addresses || ''
    emails = email_addresses.split(",").collect{|email| email.strip }.uniq
    
    emails.each{ |email|
      unless email =~ /[\w._%-]+@[\w.-]+.[a-zA-Z]{2,4}/
        invalid_emails << email
      end        
    }
    unless invalid_emails.empty?
      record.errors.add(:email_addresses, " included invalid addresses: <ul>"+invalid_emails.collect{|email| '<li>'+email+'</li>' }.join+"</ul>")
      record.email_addresses = (emails - invalid_emails).join(', ')
    end
  end

  attr_accessible :email_addresses, :message

  def send_invite
    emails = self.email_addresses.split(",").collect{|email| email.strip }.uniq 
    emails.each{|email|
      UserNotifier.signup_invitation(email, self.user, self.message).deliver
    }
  end
  
end
