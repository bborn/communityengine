require File.dirname(__FILE__) + '/../test_helper'

class PhotoTest < Test::Unit::TestCase
  fixtures :photos

  # Replace this with your real tests.
  def test_should_find_related_photos
    photos = Photo.find_related_to(photos(:library_pic))
    assert photos.empty?
  end
  
  def test_should_find_recent
    photos = Photo.find_recent(:limit => 1)
    assert_equal photos.size, 1
  end
  
  def test_should_find_previous_photo
    previous = photos(:library_pic).previous_photo
    assert_equal previous, photos(:another_pic)
  end
  
  def test_should_find_next_photo
    next_photo = photos(:another_pic).next_photo
    assert_equal next_photo, photos(:library_pic)
  end  
  
end
