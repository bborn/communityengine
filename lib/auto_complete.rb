require 'auto_complete/auto_complete'
require 'auto_complete/auto_complete_macros_helper'

ActionController::Base.send :include, AutoComplete
ActionController::Base.helper AutoCompleteMacrosHelper