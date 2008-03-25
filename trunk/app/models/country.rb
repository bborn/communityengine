class Country < ActiveRecord::Base
  has_many :metro_areas
  
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
  
end
