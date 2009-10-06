class Vote < ActiveRecord::Base
  validates_presence_of :user_id
  validates_presence_of :poll
  validates_presence_of :choice
  validates_uniqueness_of :user_id, :scope => :poll_id, :message => 'has already voted.'
    
  belongs_to :poll
  belongs_to :user
  belongs_to :choice, :counter_cache => true

  after_save :update_poll_votes_count
  
  def update_poll_votes_count
    votes_count = Choice.sum(:votes_count, :conditions => {:poll_id => self.poll_id})
    self.poll.votes_count = votes_count
    self.poll.save!
  end

end
