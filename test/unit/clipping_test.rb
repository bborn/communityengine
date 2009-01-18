require File.dirname(__FILE__) + '/../test_helper'

class ClippingTest < Test::Unit::TestCase
  fixtures :clippings, :tags, :taggings, :users, :roles

  def teardown
    Asset.destroy_all
  end

  def test_should_require_user_id
    clipping = Clipping.new
    assert !clipping.valid?
    assert clipping.errors.on(:user)
  end

  def test_should_find_related_clippings
    google_clip = clippings(:google)
    related = Clipping.find_related_to(google_clip)
    assert_equal [ clippings(:yahoo_related_to_google) ], related
  end

  def test_should_find_recent
    clippings = Clipping.find_recent(:limit => 1)
    assert_equal clippings.size, 1
  end
  
  def test_should_find_previous_clipping
    previous = clippings(:google).previous_clipping
    assert_equal previous, clippings(:yahoo_related_to_google)
  end
  
  def test_should_find_next_clipping
    next_clipping = clippings(:yahoo_related_to_google).next_clipping
    assert_equal next_clipping, clippings(:google)
  end
  
  def test_should_get_clipping_image
    assert_difference Asset, :count, 4 do
      c = Clipping.create(:user => users(:quentin), :url => 'http://example.com', :image_url => 'http://www.google.com/intl/en_ALL/images/logo.gif')
      c.save!
    end
  end
  
  def test_should_require_valid_image_url
    assert_no_difference Clipping, :count do
      c = Clipping.create(:user => users(:quentin), :url => 'http://example.com', :image_url => 'hijack!')    
    end
  end
  
end
