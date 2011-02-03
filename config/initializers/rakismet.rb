if configatron.akismet_key
  Rakismet::KEY  = configatron.akismet_key
  Rakismet::URL  = APP_URL.gsub("http://", '')
  Rakismet::HOST = 'rest.akismet.com'
end