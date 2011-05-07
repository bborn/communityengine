require File.dirname(__FILE__) + '/../test_helper'

class ConfigurationTest < ActiveSupport::TestCase

  test "tiny mce should load the valid options on init" do
    assert_not_nil TinyMCE::Configuration.valid_options
  end

  test "tiny mce should allow a certain number of options" do
    assert_equal 141, TinyMCE::Configuration.valid_options.size
  end

  test "the valid method accepts valid options as strings or symbols" do
    configuration = TinyMCE::Configuration.new
    assert configuration.valid?('mode')
    assert configuration.valid?('plugins')
    assert configuration.valid?('theme')
    assert configuration.valid?(:mode)
    assert configuration.valid?(:plugins)
    assert configuration.valid?(:theme)
  end

  test "the valid method detects invalid options as strings or symbols" do
    configuration = TinyMCE::Configuration.new
    assert !configuration.valid?('a_fake_option')
    assert !configuration.valid?(:wrong_again)
  end

  test "plugins can be set in the options validator and be valid" do
    configuration = TinyMCE::Configuration.new
    configuration.plugins = Array.new
    assert !configuration.valid?('paste_auto_cleanup_on_paste')
    configuration.plugins = %w{paste}
    assert configuration.valid?('paste_auto_cleanup_on_paste')
  end

  test "plugins can be added at a later stage in the script" do
    configuration = TinyMCE::Configuration.new
    configuration.plugins = %w{paste}
    assert configuration.valid?('paste_auto_cleanup_on_paste')
    configuration.plugins += %w{fullscreen}
    assert ['paste', 'fullscreen'], configuration.plugins
    assert configuration.valid?('fullscreen_overflow')
  end

  test "advanced theme container options get through based on regex" do
    configuration = TinyMCE::Configuration.new
    assert configuration.valid?('theme_advanced_container_content1')
    assert configuration.valid?('theme_advanced_container_content1_align')
    assert configuration.valid?('theme_advanced_container_content1_class')
    assert !configuration.valid?('theme_advanced_container_[content]')
    assert !configuration.valid?('theme_advanced_container_[content]_align')
    assert !configuration.valid?('theme_advanced_container_[content]_class')
  end
  
end
