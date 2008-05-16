require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  fixtures :categories, :posts
  
  def test_get
    assert_equal Category.get(:questions), categories(:questions)
    assert_equal Category.get(:how_to), categories(:how_to)    
    assert_equal Category.get(:inspiration), categories(:inspiration)        
    assert_equal Category.get(:news), categories(:news)        
    assert_equal Category.get(:talk), categories(:talk)
  end
  
  def test_should_get_all_names
    assert_equal ["How To", "Inspiration", "Questions", "Talk", "News"], Category.all_names
  end
  
  def test_should_get_recent_count
    assert_equal 3, Category.get_recent_count(:how_to)
  end
  
  def test_should_display_new_post_text
    assert_equal "Write a 'Questions' post", Category.get(:questions).display_new_post_text
  end


end