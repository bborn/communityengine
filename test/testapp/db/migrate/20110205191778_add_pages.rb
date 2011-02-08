class AddPages < ActiveRecord::Migration
  def self.up
    # Page.create(:title=> t(:about), :body=>"<p>#{:your_about_text_goes_here.l}</p>", :published_as=>"live", :page_public=>true)
    # Page.create(:title=>:faq.l, :body=>"<p>#{:your_faq_text_goes_here.l}</p>", :published_as=>"live", :page_public=>true)
    
    #this shouldn't happen in a migration
  end

  def self.down
    # Page.destroy_all
  end
end
