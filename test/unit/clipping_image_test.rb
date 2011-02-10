require File.dirname(__FILE__) + '/../test_helper'

class ClippingImageTest < ActiveSupport::TestCase
  fixtures :clippings, :users, :roles
  
  def teardown
    Asset.destroy_all
  end
    
  def test_should_be_created
    image = ClippingImage.new(:attachable => clippings(:google))
    io = image.data_from_url('http://www.google.com/intl/en_ALL/images/logo.gif')            
    image.asset = io
    assert image.save!
  end

end
