require 'caboose/ez'
require 'caboose/clause'
require 'caboose/condition'
require 'caboose/hash'

ActiveRecord::Base.send :include, Caboose::EZ