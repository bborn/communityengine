class AddUsToExistingMetroAreas < ActiveRecord::Migration
  def self.up
    MetroArea.find(:all).each do |m|
      m.update_attribute(:country, Country.get(:us))
    end
  end

  def self.down
    MetroArea.find(:all).each do |m|
      m.update_attribute(:country, nil)
    end
  end
end
