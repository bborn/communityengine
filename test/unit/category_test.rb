require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  fixtures :categories
  
  def test_get
    assert_equal Category.get(:questions), categories(:questions)
    assert_equal Category.get(:how_to), categories(:how_to)    
    assert_equal Category.get(:inspiration), categories(:inspiration)        
    assert_equal Category.get(:news), categories(:news)        
    assert_equal Category.get(:talk), categories(:talk)
  end

end