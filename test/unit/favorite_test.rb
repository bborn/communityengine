require File.dirname(__FILE__) + '/../test_helper'

class FavoriteTest < Test::Unit::TestCase
  fixtures :clippings, :users, :roles
  
  def setup
    Favorite.destroy_all
  end
  
  def test_should_be_created
    f = Favorite.new(:favoritable => clippings(:google), :ip_address => '127.0.0.1')
    assert f.save!
  end
  
  def test_should_be_invalid_without_favoritable
    f = Favorite.new(:ip_address => '127.0.0.1')
    assert !f.valid?
    assert f.errors.on(:favoritable)    
  end
  
  def test_should_update_counter_on_clipping
    f = Favorite.new(:favoritable => clippings(:google), :ip_address => '127.0.0.1')
    f2 = Favorite.new(:favoritable => clippings(:google), :ip_address => '127.0.0.2')
    assert_difference clippings(:google), :favorited_count, 2 do
      f.save!
      f2.save!
    end
  end
  
  def test_should_decrease_counter_when_destroyed
    f = Favorite.new(:favoritable => clippings(:google), :ip_address => '127.0.0.1')
    f.save!    
    
    assert_difference clippings(:google), :favorited_count, -1 do
      f.destroy
    end
  end  
  
  def test_same_user_should_not_favorite_twice
    Favorite.create!(:favoritable => clippings(:google), :ip_address => '127.0.0.1', :user => users(:quentin))

    assert_raise ActiveRecord::RecordInvalid do  
      Favorite.create!(:favoritable => clippings(:google), :ip_address => '127.0.0.1', :user => users(:quentin))        
    end

  end

  def test_same_ip_address_should_not_favorite_twice
    Favorite.create!(:favoritable => clippings(:google), :ip_address => '127.0.0.1')

    assert_raise ActiveRecord::RecordInvalid do  
      Favorite.create!(:favoritable => clippings(:google), :ip_address => '127.0.0.1')        
    end
  end

  def test_should_find_by_remote_ip
    Favorite.create!(:favoritable => clippings(:google), :ip_address => '127.0.0.1')
    assert Favorite.find_by_user_or_ip_address(clippings(:google), nil, '127.0.0.1')    
  end

  def test_should_find_by_user_or_ip
    Favorite.create!(:favoritable => clippings(:google), :ip_address => '127.0.0.1', :user => users(:quentin))
    assert Favorite.find_by_user_or_ip_address(clippings(:google), users(:quentin))    
  end

  def test_should_find_favorites_by_user
    favorite = Favorite.create!(:favoritable => clippings(:google), :ip_address => '127.0.0.1', :user => users(:quentin))
    assert Favorite.find_favorites_by_user(users(:quentin)).include?(favorite)
  end

end