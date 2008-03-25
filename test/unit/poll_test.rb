require File.dirname(__FILE__) + '/../test_helper'

class PollTest < Test::Unit::TestCase

  def test_should_be_invalid_without_question
    p = Poll.new(:question => nil)
    assert !p.valid?
    assert p.errors.on(:question)
  end
  
  def test_should_be_invalid_without_post
    p = Poll.new(:post => nil)
    assert !p.valid?
    assert p.errors.on(:post)
  end
  
  def test_should_create_poll
    assert Poll.create(:post_id => 1, :question => 'Do you like things?')
  end
  
  def test_should_find_popular
    assert Poll.find_popular
  end

end