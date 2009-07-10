require File.dirname(__FILE__) + '/../../../../config/environment'
require File.dirname(__FILE__) + '/../lib/professionalnerd/simple_private_messages/has_private_messages_extensions'
require File.dirname(__FILE__) + '/../lib/professionalnerd/simple_private_messages/private_message_extensions'
begin require 'redgreen'; rescue LoadError; end

#ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection(ENV['DB'] || 'sqlite3')
fixture_path = File.dirname(__FILE__) + '/fixtures/'
Dependencies.load_paths.insert(0, fixture_path)
load(File.dirname(__FILE__) + '/schema.rb')

class Test::Unit::TestCase
  
  def create_user(options = {})
    return User.create({:login => "Dolores"}.merge(options))
  end

  def create_message(options = {})
    return Message.create({:sender => @george,
                           :recipient => @jerry,
                           :subject => "Frolf, Jerry!",
                           :body => "Frolf, Jerry! Frisbee golf!"}.merge(options))
  end
  
end