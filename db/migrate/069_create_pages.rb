class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :title
      t.text :body
      t.string :published_as, :limit => 16, :default => 'draft'
      t.boolean :page_public, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
