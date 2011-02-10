#hack to get around the fact that the StaticPage model no longer exists
class StaticPage < ActiveRecord::Base
end


class CreatePages < ActiveRecord::Migration
  def self.up    
    create_table :pages do |t|
      t.string :title
      t.text :body
      t.string :published_as, :limit => 16, :default => 'draft'
      t.boolean :page_public, :default => true
      t.timestamps
    end
    
    #remove static pages table id needed and migrate StaticPages to Pages
    if ActiveRecord::Base.connection.tables.include?('static_pages')
      StaticPage.all.each do |page|
        Page.create(:title => page.title, :body => page.content, :published_as=>"live", :page_public => true)
      end

      drop_table :static_pages          
    end
  end

  def self.down
    drop_table :pages
  end
end
