require File.dirname(__FILE__) + '/../test_helper'

class ChoiceTest < Test::Unit::TestCase

  def test_should_require_poll
    c = Choice.new
    assert !c.valid?
  end
end
