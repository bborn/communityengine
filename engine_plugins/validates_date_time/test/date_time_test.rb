require File.dirname(__FILE__) + '/abstract_unit'

class DateTimeTest < Test::Unit::TestCase
  fixtures :people
  
  def test_various_formats
    formats = {
      '2006-01-01 01:01:01' => /Jan 01 01:01:01 [\w ]+ 2006/,
      '2/2/06 7pm'          => /Feb 02 19:00:00 [\w ]+ 2006/,
      '10 AUG 04 6.23am'    => /Aug 10 06:23:00 [\w ]+ 2004/,
      '6 June 1981 10 10'   => /Jun 06 10:10:00 [\w ]+ 1981/
    }
    
    formats.each do |value, result|
      assert_update_and_match result, :date_and_time_of_birth => value
    end
    
    with_us_date_format do
      formats.each do |value, result|
        assert_update_and_match result, :date_and_time_of_birth => value
      end
    end
  end
  
  def test_invalid_formats
    ['29 Feb 06 1am', '1 Jan 06', '7pm'].each do |value|
      assert_no_update_and_errors :date_and_time_of_birth => value
    end
    assert_match /date time/, p.errors[:date_and_time_of_birth]
  end
    
  def test_multi_parameter_attribute_assignment_with_valid_date_time
    attributes = { 'time_of_birth(1i)' => '2006', 'time_of_birth(2i)' => '2', 'time_of_birth(3i)' => '20', 'time_of_birth(4i)' => '23', 'time_of_birth(5i)' => '10', 'time_of_birth(6i)' => '40' }
    assert_nothing_raised do
      assert p.update_attributes(attributes)
    end
    assert_equal Time.local(2006, 2, 20, 23, 10, 40), p.time_of_birth
  end
  
  def test_multi_parameter_attribute_assignment_with_invalid_date_time
    attributes = { 'time_of_birth(1i)' => '2006', 'time_of_birth(2i)' => '2', 'time_of_birth(3i)' => '10', 'time_of_birth(4i)' => '30', 'time_of_birth(5i)' => '88', 'time_of_birth(6i)' => '100' }
    assert_nothing_raised do
      assert !p.update_attributes(attributes)
    end
    assert p.errors[:time_of_birth]
  end
  
  def test_incomplete_multi_parameter_attribute_assignment
    assert_nothing_raised do
      assert !p.update_attributes('time_of_birth(1i)' => '2006', 'time_of_birth(2i)' => '1')
    end
    assert p.errors[:time_of_birth]
  end
end
