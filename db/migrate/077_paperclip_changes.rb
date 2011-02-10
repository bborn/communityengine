class PaperclipChanges < ActiveRecord::Migration
  def up
    rename_column :photos, :filename, :photo_file_name
    rename_column :photos, :content_type, :photo_content_type
    rename_column :photos, :size, :photo_file_size
    add_column :photos, :photo_updated_at, :datetime
        
    rename_column :assets, :filename, :asset_file_name
    rename_column :assets, :content_type, :asset_content_type
    rename_column :assets, :size, :asset_file_size        
    add_column :assets, :asset_updated_at, :datetime       
    
    rename_column :homepage_features, :filename, :image_file_name
    rename_column :homepage_features, :content_type, :image_content_type
    rename_column :homepage_features, :size, :image_file_size        
    add_column :homepage_features, :image_updated_at, :datetime       
    
    
  end

  def down
    rename_column :photos, :photo_file_name, :filename
    rename_column :photos, :photo_content_type, :content_type
    rename_column :photos, :photo_file_size, :size
    remove_column :photos, :photo_updated_at
        
    rename_column :assets, :asset_file_name, :filename
    rename_column :assets, :asset_content_type, :content_type
    rename_column :assets, :asset_file_size, :size
    remove_column :assets, :asset_updated_at    
    
    rename_column :homepage_feature, :image_file_name, :filename
    rename_column :homepage_feature, :image_content_type, :content_type
    rename_column :homepage_feature, :image_file_size, :size
    remove_column :homepage_feature, :image_updated_at    
    
  end
end
