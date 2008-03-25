require File.dirname(__FILE__) + '/abstract_unit'

class TimeTest < Test::Unit::TestCase
  fixtures :people
  
  def test_no_time_checking
    assert p.update_attributes(:time_of_birth => nil, :time_of_death => nil, :time_of_death => nil)
  end
  
  def test_with_seconds
    { '03:45:22' => /03:45:22/, '09:10:27' => /09:10:27/ }.each do |value, result|
      assert_update_and_match result, :time_of_birth => value
    end
  end
  
  def test_12_hour_with_minute
    { '7.20pm' => /19:20:00/, ' 1:33 AM' => /01:33:00/, '11 28am' => /11:28:00/ }.each do |value, result|
      assert_update_and_match result, :time_of_birth => value
    end
  end
  
  def test_12_hour_without_minute
    { '11 am' => /11:00:00/, '7PM ' => /19:00:00/, ' 1Am' => /01:00:00/, '12pm' => /12:00:00/, '12.00pm' => /12:00:00/, '12am' => /00:00:00/ }.each do |value, result|
      assert_update_and_match result, :time_of_birth => value
    end
  end
  
  def test_24_hour
    { '22:00' => /22:00:00/, '10 23' => /10:23:00/, '01 01' => /01:01:00/ }.each do |value, result|
      assert_update_and_match result, :time_of_birth => value
    end
  end
  
  def test_time_objects
    { Time.gm(2006, 2, 2, 22, 30) => /22:30:00/, '2pm' => /14:00:00/, Time.gm(2006, 2, 2, 1, 3) => /01:03:00/ }.each do |value, result|
      assert_update_and_match result, :time_of_birth => value
    end
  end
  
  def test_invalid_formats
    ['1 PPM', 'lunchtime', '8..30', 'chocolate', '29am'].each do |value|
      assert !p.update_attributes(:time_of_birth => value)
    end
    assert_match /time/, p.errors[:time_of_birth]
  end
  
  def test_after
    assert_no_update_and_errors_match /must be after/, :time_of_death => '6pm'
    
    assert p.update_attributes(:time_of_death => '8pm')
    assert p.update_attributes(:time_of_death => nil, :time_of_birth => Time.gm(2001, 1, 1, 9))
    
    assert_no_update_and_errors_match /must be after/, :time_of_death => '7am'
  end
  
  def test_before
    assert_no_update_and_errors_match /must be before/, :time_of_birth => Time.now + 1.day
    assert p.update_attributes(:time_of_birth => Time.now - 1)
  end
  
  def test_blank
    assert p.update_attributes(:time_of_birth => "")
    assert_nil p.time_of_birth
  end
end
