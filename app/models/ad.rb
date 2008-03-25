class Ad < ActiveRecord::Base
  FREQUENCIES = 1..10
  AUDIENCES = %w(all logged_in logged_out)

  validates_presence_of :html
  validates_inclusion_of :audience, :in => AUDIENCES
  validates_inclusion_of :frequency, :in => FREQUENCIES  
  
  def self.display(location, logged_in = false)
    ads = find(:all, 
      :conditions => ["location = ? 
        AND published = ? 
        AND (time_constrained = ? OR (start_date > ? AND end_date < ?))
        AND (audience IN (?) )", 
        location.to_s, true, false, Time.now, Time.now, audiences_for(logged_in) ])
        
    ad = random_weighted(ads.map{|a| [a, a.frequency] })
    ad ? ad.html : ''
  end
  
  def self.audiences_for(logged_in)
    ["all", "logged_#{logged_in ? 'in' : 'out'}"]
  end
  
  def self.frequencies_for_select
    FREQUENCIES.map{|f| [f, f.to_s]}
  end
  
  def self.audiences_for_select
    AUDIENCES.map{|a| [a, a.to_s]}
  end  
  
  def self.random_weighted(items)
    total = 0
    pick = nil
    items.each do |item, weight|
      pick = item if rand(total += weight) < weight
    end
    pick
  end    

end