class MigrateToActsAsTaggableOn < ActiveRecord::Migration
  
  def self.change

    change_table :taggings do |t|
      t.references :tagger, :polymorphic => true
      t.string :context, :limit => 128
      t.datetime :created_at      
    end
    
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]    
  end  
  
  
end