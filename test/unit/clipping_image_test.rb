require File.dirname(__FILE__) + '/../test_helper'

class ClippingImageTest < Test::Unit::TestCase
  fixtures :clippings, :users, :roles
  
  def teardown
    Asset.destroy_all
  end
    
  def test_should_be_created
    ci = ClippingImage.new(:attachable => clippings(:google))
    io = ci.data_from_url('http://www.google.com/intl/en_ALL/images/logo.gif')            
    ci.uploaded_data = io
    assert ci.save!
  end

end
