class CreateStaticPages < ActiveRecord::Migration
  def self.up
    create_table :static_pages do |t|
      t.string :title
      t.string :url
      t.text :content
      t.boolean :active, :default => false
      t.string :visibility, :default => 'Everyone' 

      t.timestamps
    end
  end

  def self.down
    drop_table :static_pages
  end
end
