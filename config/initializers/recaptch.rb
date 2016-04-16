Recaptcha.configure do |config|
  config.public_key  = ENV['RECAPTCHA_PUBLIC'] #site key
  config.private_key = ENV['RECAPTCHA_SECRET'] #secreat key
  config.api_version = 'v2'
end