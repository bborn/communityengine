require File.dirname(__FILE__) + '/../test_helper'

class CountryTest < Test::Unit::TestCase
  fixtures :countries, :metro_areas

  def test_should_find_united_states
    country = Country.get(:us)
    assert !country.nil?
  end
  
  def test_should_find_countries_with_metro_areas
    c = Country.find_countries_with_metros
    assert_equal c.size, 3
  end
end
