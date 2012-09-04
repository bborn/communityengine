# see last line where we create an admin if there is none, asking for email and password

def prompt_for_admin_password
  password = ask('Password [communityengine]: ', String) do |q|
    q.echo = false
    q.validate = /^(|.{5,40})$/
    q.responses[:not_valid] = "Invalid password. Must be at least 5 characters long."
    q.whitespace = :strip
  end
  password = "communityengine" if password.blank?
  password
end

def prompt_for_admin_login
  login = ask('Login [admin]: ', String) do |q|
    q.echo = true
    q.whitespace = :strip
  end
  login = "admin" if login.blank?
  login
end  

def create_admin_user
  if ENV['AUTO_ACCEPT']
    password =  "communityengine"
    login =  "admin"          
  else
    require 'highline/import' 
    puts "Create the admin user (press enter for defaults)."
    login = prompt_for_admin_login 
    password = prompt_for_admin_password 
  end
  attributes = {
    :password => password,
    :password_confirmation => password,
    :email => 'admin@example.com',
    :login => login,
    :birthday => 30.years.ago
  }

  
  if User.find_by_login(login)
    puts "\nWARNING: There is already a user with the login: #{login}, so no account changes were made.  If you wish to create an additional admin user, please run 'rake community_engine:create_admin' again with a different login.\n\n"
  else
    admin = User.create(attributes)
    # create an admin role and and assign the admin user to that role
    admin.role = Role[:admin]
    admin.activate
    puts "\nINFO: User with admin priviliges was created.\n" if admin.save!
  end      
end

load File.join(Rails.root, 'vendor', 'plugins', 'community_engine', 'app', 'models', 'user.rb')

create_admin_user 
