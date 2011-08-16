class AddingAds < ActiveRecord::Migration
  def self.up
    create_table :ads do |t|
      t.column :name, :string
      t.column :html, :text
      t.column :frequency, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.column :location, :string
      t.column :published, :boolean, :default => false
      t.column :time_constrained, :boolean, :default => false
    end
  end

  def self.down
    drop_table :ads
  end
end
