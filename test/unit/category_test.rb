require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  fixtures :categories, :posts
        
  def test_should_display_new_post_text
    c = categories(:questions)
    c.new_post_text = "Ask a question"
    c.save!
    assert_equal "Ask a question", c.reload.display_new_post_text
  end


end