require 'rake/clean'

namespace :community_engine do

  desc  'Assign admin role to user. Usage: rake community_engine:make_admin email=admin@foo.com'
  task :make_admin => :environment do
    email = ENV["email"]
    user = User.find_by_email(email)
    if user
      user.role = Role[:admin]
      user.save!
      puts "#{user.login} (#{user.email}) was made into an admin."
    else
      puts "There is no user with the e-mail '#{email}'."
    end
  end

end
