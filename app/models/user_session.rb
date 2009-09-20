class UserSession < Authlogic::Session::Base
  remember_me_for 2.weeks
  remember_me false
end
