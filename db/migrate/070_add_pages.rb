class AddPages < ActiveRecord::Migration
  def self.up
    # Don't add this stuff in a migration.
    # Page.create(:title=>:about.l, :body=>"<p>#{:your_about_text_goes_here.l}</p>", :published_as=>"live", :page_public=>true)
    # Page.create(:title=>:faq.l, :body=>"<p>#{:your_faq_text_goes_here.l}</p>", :published_as=>"live", :page_public=>true)
  end

  def self.down
    Page.destroy_all
  end
end
