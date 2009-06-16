class Event < ActiveRecord::Base
  validates_presence_of :name, :identifier => 'validates_presence_of_name'
  validates_presence_of :start_time
  validates_presence_of :end_time
  validates_presence_of :user

  belongs_to :user
  belongs_to :metro_area

  attr_protected :user_id
  
  named_scope :upcoming, :order => 'start_time', :conditions => ['end_time > ?' , Time.now ]
  named_scope :past, :order => 'start_time DESC', :conditions => ['end_time <= ?' , Time.now ]
  
  
  acts_as_commentable    
  
  def time_and_date
    if spans_days?
      string = "#{start_time.strftime("%B %d")} to #{end_time.strftime("%B %d %Y")}"
    else
      string = "#{start_time.strftime("%B %d, %Y")}, #{start_time.strftime("%I:%M %p")} - #{end_time.strftime("%I:%M %p")}"
    end
  end

  def location
    metro_area ? metro_area.name : ''
  end
  
  def spans_days?
    (end_time - start_time) >= 86400
  end
  
  protected
  def validate
    errors.add("start_time", " must be before end time") unless start_time && end_time && (start_time < end_time)
  end  
  
end
