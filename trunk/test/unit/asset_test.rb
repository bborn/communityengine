require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < Test::Unit::TestCase
  fixtures :clippings, :users
  
  def teardown
    Asset.destroy_all
  end
  
  def test_should_be_created
    a = Asset.new(:attachable => clippings(:google))
    assert a.save!
  end

end