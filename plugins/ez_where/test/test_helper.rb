require 'test/unit'
require 'rubygems'
require 'active_record'
require 'active_record/fixtures'
require 'active_support'
require 'active_support/breakpoint'

require File.dirname(__FILE__) + '/../lib/caboose/ez'
require File.dirname(__FILE__) + '/../lib/caboose/clause'
require File.dirname(__FILE__) + '/../lib/caboose/condition'
require File.dirname(__FILE__) + '/../lib/caboose/hash'

ActiveRecord::Base.send :include, Caboose::EZ

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

driver = config[ENV['db'] ? ENV['db'] : 'sqlite3']

ActiveRecord::Base.establish_connection(driver)

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

ActiveRecord::Base.logger.silence { load(File.dirname(__FILE__) + "/schema.rb") }

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"

$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase #:nodoc:
  
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end
  
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = false

end

class Article < ActiveRecord::Base
  
  belongs_to :author
  has_many   :comments
  
end

class Author < ActiveRecord::Base
  
  has_many :articles
  
end

class Comment < ActiveRecord::Base
  
  has_many :articles
  belongs_to :author
  
end