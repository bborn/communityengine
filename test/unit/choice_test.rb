require 'test_helper'

class ChoiceTest < ActiveSupport::TestCase

  def test_should_require_poll
    c = Choice.new
    assert !c.valid?
  end
end
