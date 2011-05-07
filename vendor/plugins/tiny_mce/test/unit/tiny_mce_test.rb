require File.dirname(__FILE__) + '/../test_helper'

class TinyMCETest < ActiveSupport::TestCase

  test "including tiny mce module into a class should provide uses_tiny_mce method" do
    test_controller = TestController.new
    assert !test_controller.class.respond_to?(:uses_tiny_mce)
    TestController.send(:include, TinyMCE::Base)
    assert test_controller.class.respond_to?(:uses_tiny_mce)
  end

  test "tiny mce plugin is included into action controller base and uses_tiny_mce method available" do
    assert ApplicationController.respond_to?(:uses_tiny_mce)
  end

end
