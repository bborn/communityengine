require 'test_helper'

class AdTest < ActiveSupport::TestCase
  fixtures :all

  test "should display published, currently-running ad to all users" do
    [false, true].each do |t|
      html = Ad.display(:homepage_s1, t)
      assert_equal(html, ads(:hgtv).html)
    end
  end
  
  test "should get audience string for logged_in status" do
    assert_equal Ad.audiences_for(false), ['all', 'logged_out']
    assert_equal Ad.audiences_for(true), ['all', 'logged_in']    
  end
  
  test "should get frequencies for select tag" do
    assert_equal Ad.frequencies_for_select, (1..10).map{|f| [f, f.to_s]}
  end
  
  test "should get audiences for select tag" do
    assert_equal Ad.audiences_for_select, %w(all logged_in logged_out).map{|f| [f, f.to_s]}    
  end

end
