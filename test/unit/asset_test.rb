require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  fixtures :clippings, :users, :roles
  
  def teardown
    Asset.destroy_all
  end
  
  def test_should_be_created
    a = Asset.new(:attachable => clippings(:google))
    assert a.save!
  end

end