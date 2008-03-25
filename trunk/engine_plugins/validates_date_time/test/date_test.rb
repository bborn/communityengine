require File.dirname(__FILE__) + '/abstract_unit'

class DateTest < Test::Unit::TestCase
  fixtures :people
  
  def test_no_date_checking
    assert p.update_attributes(:date_of_birth => nil, :date_of_death => nil)
  end
  
  def test_no_allow_nil
    assert !p.update_attributes(:required_date => "")
    assert p.errors[:required_date]
  end
  
  # Test 1/1/06 format
  def test_first_format
    { '1/1/01'  => '2001-01-01', '29/10/2005' => '2005-10-29', '8\12\63' => '1963-12-08',
      '07/06/2006' => '2006-06-07', '11\1\06' => '2006-01-11', '10.6.05' => '2005-06-10' }.each do |value, result|
      assert_update_and_equal result, :date_of_birth => value
    end
  end
  
  # Test 1 Jan 06 and 1 January 06 formats
  def test_second_format
    { '19 Mar 60'    => '1960-03-19', '22 dec 1985'      => '1985-12-22',
      '24 August 00' => '2000-08-24', '25 December 1960' => '1960-12-25'}.each do |value, result|
      assert_update_and_equal result, :date_of_birth => value
    end
  end
  
  # Test February 4 2006 formats
  def test_third_format
    { 'february 4 06' => '2006-02-04', 'DECember 25 1850' => '1850-12-25' }.each do |value, result|
      assert_update_and_equal result, :date_of_birth => value
    end
  end
  
  def test_iso_format
    { '2006-01-01' => '2006-01-01', '1900-04-22' => '1900-04-22' }.each do |value, result|
      assert_update_and_equal result, :date_of_birth => value
    end
  end
  
  def test_invalid_formats
    ['aksjhdaksjhd', 'meow', 'chocolate',
     '221 jan 05', '21 JAN 001', '1 Jaw 00', '1 Febrarary 2003', '30/2/06',
     '1/2/3/4', '11/22/33', '10/10/990', '189 /1 /9', '12\ f m'].each do |value|
      assert !p.update_attributes(:date_of_birth => value), "#{value} should not be valid"
    end
    assert_match /date/, p.errors[:date_of_birth]
  end
  
  def test_validation
    p.valid?
    p.valid?
  end
  
  def test_date_objects
    assert_update_and_equal '2006-01-01', :date_of_birth => Date.new(2006, 1, 1)
    assert_update_and_equal '1963-04-05', :date_of_birth => Date.new(1963, 4, 5)
  end
  
  def test_before_and_after
    assert p.update_attributes(:date_of_death => '1950-01-01')
    
    assert_no_update_and_errors_match /before/, :date_of_death => (Date.today + 2).to_s
    assert_no_update_and_errors_match /before/, :date_of_death => Date.new(2030, 1, 1)
    
    assert p.update_attributes(:date_of_birth => '1950-01-01', :date_of_death => nil)
    assert_no_update_and_errors_match /after/, :date_of_death => '1949-01-01'
    assert p.update_attributes(:date_of_death => Date.new(1951, 1, 1))
  end
  
  def test_before_and_after_with_custom_message
    assert_no_update_and_errors_match /avant/, :date_of_arrival => 2.years.from_now.to_date, :date_of_departure => 2.years.ago.to_date
    assert_no_update_and_errors_match /apres/, :date_of_arrival => '1792-03-03'
  end
  
  def test_dates_with_unknown_year
    assert p.update_attributes(:date_of_birth => '9999-12-11')
    assert p.update_attributes(:date_of_birth => Date.new(9999, 1, 1))
  end
  
  def test_us_date_format
    with_us_date_format do
      {'1/31/06'  => '2006-01-31', '28 Feb 01'  => '2001-02-28',
       '10/10/80' => '1980-10-10', 'July 4 1960' => '1960-07-04',
       '2006-03-20' => '2006-03-20'}.each do |value, result|
        assert_update_and_equal result, :date_of_birth => value
      end
    end
  end
  
  def test_blank
    assert p.update_attributes(:date_of_birth => " ")
    assert_nil p.date_of_birth
  end
  
  def test_conversion_of_restriction_result
    assert !p.update_attributes(:date_of_death => Date.new(2001, 1, 1), :date_of_birth => Date.new(2005, 1, 1))
    assert_match /Date of birth/, p.errors[:date_of_death]
  end
  
  def test_multi_parameter_attribute_assignment_with_valid_date
    assert_nothing_raised do
      assert p.update_attributes('date_of_birth(1i)' => '2006', 'date_of_birth(2i)' => '2', 'date_of_birth(3i)' => '10')
    end
    assert_equal Date.new(2006, 2, 10), p.date_of_birth
  end
  
  def test_multi_parameter_attribute_assignment_with_invalid_date
    assert_nothing_raised do
      assert !p.update_attributes('date_of_birth(1i)' => '2006', 'date_of_birth(2i)' => '2', 'date_of_birth(3i)' => '30')
    end
    assert p.errors[:date_of_birth]
  end
  
  def test_incomplete_multi_parameter_attribute_assignment
    assert_nothing_raised do
      assert !p.update_attributes('date_of_birth(1i)' => '2006', 'date_of_birth(2i)' => '1', 'date_of_birth(3i)' => '')
    end
    assert p.errors[:date_of_birth]
  end
end
