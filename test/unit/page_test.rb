require 'test_helper'
require 'hpricot'
    
class PageTest < ActiveSupport::TestCase
  fixtures :pages

  def test_should_find_including_unpublished
    page = pages(:draft_page)
    page.save_as_draft
    assert Page.unscoped.all.include?(page)
  end
  
  def test_default_find_should_not_find_drafts
    page = pages(:draft_page)
    page.save_as_draft
    assert !Page.all.include?(page)    
  end
  
  def test_default_find_should_find_published
    page = pages(:custom_page)
    page.save
    assert Page.find(:all).include?(page)    
  end

end
