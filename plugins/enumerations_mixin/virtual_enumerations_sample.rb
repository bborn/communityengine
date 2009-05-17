# Copyright (c) 2005 Trevor Squires
# Released under the MIT License.  See the LICENSE file for more details.

# Copy this file to RAILS_ROOT/config/virtual_enumerations.rb
# and configure it accordingly.
ActiveRecord::VirtualEnumerations.define do |config|
  ###
  # USAGE (and don't worry, it doesn't have to be as ugly as this):
  # config.define 'ClassName', 
  #               :table_name => 'table', :extends => 'SuperclassName',
  #               :conditions => ['something = ?', "value"], :order => 'column ASC',
  #               :on_lookup_failure => :enforce_strict_literals do
  # class_evaled_functions
  # end 
  #
  # 'ClassName', :table_name and :extends are used to define your virtual class.
  # Note that 'ClassName' can be a :symbol or a 'CamelString'.  
  #
  # The :conditions, :order and :on_lookup_failure arguments are passed to
  # acts_as_enumerated in your virtual class.  See README_ENUMERATIONS for info
  # on how acts_as_enumerated works.
  #
  # The 'do' block will be class_eval'd by your virtual class after it has 
  # been loaded-on-demand.
  #
  ###
  # Okay, that's pretty long-winded.
  # Everything after the initial 'class_name' is optional so for most applications, this
  # is about as verbose as you're likely to get:
  #
  # config.define :booking_status, :order => 'position ASC'
  #
  # In the above example, ActiveRecord assumes the table will be called 'booking_statuses'
  # and the table should have a 'position' column defined.
  #
  # If you've got a bunch of enumeration classes that share the same optional parameters
  # you can pass an array of names as the first argument, saving your fingers from typing
  # config.define over and over again:
  #
  # config.define [:booking_status, :card_issuer], :order => 'position ASC'
  #
  # You can also take advantage of ActiveRecord's STI:
  #
  # config.define :enum_record, :order => 'position ASC', :table_name => 'enumrecords'
  # config.define [:booking_status, :card_issuer], :extends => 'EnumRecord'
  #
  # In the above example, all of the records are stored in the table called 'enumrecords'
  # and all acts_as_enumerated parameters are automatically inherited by the
  # subclasses (although you can override them if you want).
  # You can also use :extends to extend a non-virtual model class (that's already in 
  # your models directory) if that floats your boat.
  #
  # Finally, that strange optional 'do' block.
  # You may be struck by the need to tamper with your virtual enumeration class after
  # it has been loaded-on-demand.  This can be as simple as blessing it with a 
  # certain 'act':
  #
  # config.define :enum_record, :order => 'position ASC' do
  #   acts_as_list # but see README_ENUMERATIONS for rules about modifying your records 
  # end
  #
  # or you may be experimenting with the dark-side... singleton methods
  #
  # config.define :card_issuer do
  #   class << self[:visa]; def verify_number(arg); some_code_here; end; end
  #   class << self[:master_card]; def verify_number(arg); some_other_code_here; end; end
  # end
  #
  # For virtual enumerations, this sort of tampering *has* to be defined in the 
  # config.define do block.  This is because in development mode, rails loads and 
  # subsequently clobbers your model classes for each request.  The 'do' block will
  # be evaluated each time your model class is loaded-on-demand.
  #
  ###
  
end
