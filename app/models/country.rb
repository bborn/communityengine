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
    Country.joins(:metro_areas).where('metro_areas.id IS NOT NULL').order('countries.name ASC').to_a.uniq
  end
  
  def states
    State.joins(:metro_areas).where("metro_areas.id in (?)", metro_area_ids ).order('states.name ASC').to_a.uniq
  end
  
  def metro_area_ids
    metro_areas.map{|m| m.id }.to_ary
  end
  
end
