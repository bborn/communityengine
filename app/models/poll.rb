class Poll < ActiveRecord::Base
  has_many :choices, :dependent => :destroy
  validates_presence_of :question
  validates_presence_of :post
  has_many :votes, :dependent => :destroy
  belongs_to :post
      
  def voted?(user)
    !self.votes.find_by_user_id(user.id).nil?
  end
  
  def add_choices(choices)
    choices.each do |description|
      choice = self.choices.build(:description => description)
      choice.save
    end
  end

  def self.find_recent(options = {})
    options.reverse_merge! :limit => 5
    find(:all, :order => "polls.created_at desc", :limit => options[:limit], :include => [:post => :user])
  end

  def self.find_popular(options = {})
    options.reverse_merge! :limit => 5, :since => 10.days.ago
    
    find(:all, :order => "polls.votes_count desc", 
      :limit => options[:limit], 
      :include => [:post => :user],
      :conditions => ["polls.created_at > ?", options[:since]]
    )
  end

  def self.find_popular_in_category(category, options = {})
    options.reverse_merge! :limit => 5
    
    find(:all, :order => "polls.votes_count desc", 
      :limit => options[:limit], 
      :include => [:post => :user],
      :conditions => ['posts.category_id = ?', category.id]
      )    
  end

end
