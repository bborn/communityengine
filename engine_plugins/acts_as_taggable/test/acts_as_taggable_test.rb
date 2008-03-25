require File.dirname(__FILE__) + '/../../../test/test_helper'

class TagTest < Test::Unit::TestCase
  
  def test_badname_should_be_invalid
    t = Tag.new
    t.name = 'bad.name'
    assert !t.valid?
    assert t.errors.on(:name)
    t.name = 'bad/name'
    assert !t.valid?
    assert t.errors.on(:name)    
  end


end