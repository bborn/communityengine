if configatron.has_key?(:allow_anonymous_commenting) || configatron.has_key?(:require_captcha_on_signup)
  Recaptcha.configure do |config|
    config.site_key  = configatron.recaptcha_pub_key
    config.secret_key = configatron.recaptcha_priv_key
  end
end