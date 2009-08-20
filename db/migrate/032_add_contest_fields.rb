class AddContestFields < ActiveRecord::Migration
  def self.up
    add_column :contests, :banner_title, :string
    add_column :contests, :banner_subtitle, :string
  end

  def self.down
    remove_column :contests, :banner_title
    remove_column :contests, :banner_subtitle
  end
end
