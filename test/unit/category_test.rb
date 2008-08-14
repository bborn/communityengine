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
      
  def test_should_display_new_post_text
    c = Category.get(:questions)
    c.new_post_text = "Ask a question"
    c.save!
    assert_equal "Ask a question", Category.get(:questions).display_new_post_text
  end


end