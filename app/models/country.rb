class Country < ActiveRecord::Base
  has_many :metro_areas
  has_many :states
  
  def self.get(name)
    case name
      when :us
        c = 'United States'
    end
    self.find_by_name(c)
  end
  
  def self.find_countries_with_metros
    MetroArea.find(:all, :include => :country).collect{ |m| m.country }.sort_by{ |c| c.name }.uniq
  end
  
  def states
    State.find(:all, :include => :metro_areas, :conditions => ["metro_areas.id in (?)", metro_area_ids ]).uniq
  end
  
  def metro_area_ids
    metro_areas.map{|m| m.id }
  end
  
end
