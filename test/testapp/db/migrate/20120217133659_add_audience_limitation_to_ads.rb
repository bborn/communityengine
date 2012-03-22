class AddAudienceLimitationToAds < ActiveRecord::Migration
  def self.up
    add_column :ads, :audience, :string, :default => 'all'
  end

  def self.down
    remove_column :ads, :audience
  end
end
