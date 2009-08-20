class AddUsToUsersWithStates < ActiveRecord::Migration
  def self.up
    User.find(:all, :conditions => 'state_id is not null').each do |u|
      u.update_attribute(:country_id, Country.get(:us).id.to_i)
    end
  end

  def self.down
    User.find(:all, :conditions => 'state_id is not null').each do |u|
      u.update_attribute(:country_id, nil)
    end
  end
end
