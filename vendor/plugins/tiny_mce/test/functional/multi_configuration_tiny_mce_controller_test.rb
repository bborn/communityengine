require File.dirname(__FILE__) + '/../test_helper'

# Make a test class with full options
class MultiConfigurationTinyMCEController < ApplicationController
  uses_tiny_mce :options => { :plugins => ['spellchecker'] },
                :raw_options => '',
                :only => ['new_page','edit_page']
  uses_tiny_mce :options => { :plugins => ['paste','fullscreen'] },
                :raw_options => '',
                :only => ['edit_page']
  include TinyMCEActions
end

# Lets make sure that if routes arn't the
# defaults, these tests will still work
ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'multi_configuration_tiny_mce' do |tiny_mce|
    tiny_mce.connect '/full_tiny_mce/new_page', :action => 'new_page'
    tiny_mce.connect '/full_tiny_mce/edit_page', :action => 'edit_page'
    tiny_mce.connect '/full_tiny_mce/show_page', :action => 'show_page'
    tiny_mce.connect '/full_tiny_mce/spellchecker', :action => 'spellchecker'
  end
end

# Use non-default action names to get around possible authentication
# filters to ensure the tests work in most cases
class MultiConfigurationTinyMCEControllerTest <  ActionController::TestCase

  test "all instance variables are properly set on new" do
    get :new_page
    assert_response :success
    assert (assigns(:uses_tiny_mce) &&
            assigns(:uses_tiny_mce) == true)
    assert (assigns(:tiny_mce_configurations) &&
          assigns(:tiny_mce_configurations).is_a?(Array) &&
          assigns(:tiny_mce_configurations).first.options == { "spellchecker_rpc_url"=> "/multi_configuration_tiny_mce/spellchecker",
                                                              "plugins" => ['spellchecker'] })
  end  

  test "all instance variables are properly set on edit" do
    get :edit_page
    assert_response :success
    assert (assigns(:uses_tiny_mce) &&
          assigns(:uses_tiny_mce) == true)
    assert (assigns(:tiny_mce_configurations) &&
          assigns(:tiny_mce_configurations).is_a?(Array) &&
          assigns(:tiny_mce_configurations).first.options == { "spellchecker_rpc_url"=> "/multi_configuration_tiny_mce/spellchecker",
                                                              "plugins" => ['spellchecker'] } &&
          assigns(:tiny_mce_configurations).second.options == { "plugins" => ['paste','fullscreen'] })
  end

  test "tiny mce is only loaded on the pages specified to the uses_tiny_mce declaration" do
    get :show_page
    assert_response :success
    assert_nil assigns(:uses_tiny_mce)
    assert_nil assigns(:tiny_mce_configurations)
  end
end
