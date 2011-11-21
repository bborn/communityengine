if !configatron.allow_anonymous_commenting.nil? || !configatron.require_captcha_on_signup.nil?
  Recaptcha.configure do |config|
    config.public_key  = configatron.recaptcha_pub_key
    config.private_key = configatron.recaptcha_priv_key
  end  
end