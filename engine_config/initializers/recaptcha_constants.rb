if AppConfig.allow_anonymous_commenting || AppConfig.require_captcha_on_signup
  ENV['RECAPTCHA_PUBLIC_KEY'] = AppConfig.recaptcha_pub_key
  ENV['RECAPTCHA_PRIVATE_KEY'] = AppConfig.recaptcha_priv_key
end
