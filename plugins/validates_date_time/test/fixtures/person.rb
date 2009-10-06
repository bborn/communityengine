class Person < ActiveRecord::Base
  validates_date :date_of_birth, :allow_nil => true
  validates_date :date_of_death, :allow_nil => true, :before => Proc.new { 1.day.from_now }, :after => :date_of_birth
  
  validates_date :date_of_arrival, :allow_nil => true, :before => :date_of_departure, :after => '1 Jan 1800', :before_message => "avant %s", :after_message => "apres %s"
  
  validates_time :time_of_birth, :allow_nil => true, :before => [Proc.new { Time.now }]
  validates_time :time_of_death, :allow_nil => true, :after => [:time_of_birth, '7pm'], :before => [Proc.new { 10.years.from_now }]
  
  validates_date_time :date_and_time_of_birth, :allow_nil => true
  
  validates_date :required_date
end
