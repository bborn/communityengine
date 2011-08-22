if configatron.allow_anonymous_commenting || configatron.require_captcha_on_signup
  Recaptcha.configure do |config|
    config.public_key  = configatron.recaptcha_pub_key
    config.private_key = configatron.recaptcha_priv_key
  end  
end
