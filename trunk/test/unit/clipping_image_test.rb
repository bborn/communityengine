require File.dirname(__FILE__) + '/../test_helper'

class ClippingImageTest < Test::Unit::TestCase
  fixtures :clippings, :users  
  
  def teardown
    Asset.destroy_all
  end
    
  def test_should_be_created
    uploaded_data = UrlUpload.new('http://www.google.com/intl/en_ALL/images/logo.gif')
    ci = ClippingImage.new(:attachable => clippings(:google))
    ci.uploaded_data = uploaded_data    
    assert ci.save!
  end

end
