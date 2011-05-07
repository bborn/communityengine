require File.dirname(__FILE__) + '/../test_helper'

# Make a test class with no options
class SlimTinyMCEController < ApplicationController
  uses_tiny_mce
  include TinyMCEActions
end

# Lets make sure that if routes arn't the
# defaults, these tests will still work
ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'slim_tiny_mce' do |tiny_mce|
    tiny_mce.connect '/slim_tiny_mce/new_page', :action => 'new_page'
    tiny_mce.connect '/slim_tiny_mce/edit_page', :action => 'edit_page'
    tiny_mce.connect '/slim_tiny_mce/show_page', :action => 'show_page'
    tiny_mce.connect '/slim_tiny_mce/spellchecker', :action => 'spellchecker'
  end
end

# Use non-default action names to get around possible authentication
# filters to ensure the tests work in most cases
class SlimTinyMCEControllerTest <  ActionController::TestCase

  test "all instance variables are properly set on all pages" do
    get :new_page
    assert_instance_vars_set
    get :edit_page
    assert_instance_vars_set
    get :show_page
    assert_instance_vars_set
  end

  private

  def assert_instance_vars_set
    assert_response :success
    assert (assigns(:uses_tiny_mce) &&
            assigns(:uses_tiny_mce) == true)
    assert (assigns(:tiny_mce_configurations) &&
           assigns(:tiny_mce_configurations).is_a?(Array))

    # assert (assigns(:tiny_mce_options) &&
    #         assigns(:tiny_mce_options).is_a?(Hash))
    # assert (assigns(:raw_tiny_mce_options) &&
    #         assigns(:raw_tiny_mce_options) == '')
  end

end
