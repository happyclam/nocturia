CONSUMER_KEY = ENV['CONSUMER_KEY'] || Settings.withings.consumer_key
CONSUMER_SECRET = ENV['CONSUMER_SECRET'] || Settings.withings.consumer_secret
# CONSUMER_KEY = ENV['CONSUMER_KEY'] || Settings.twitter.consumer_key
# CONSUMER_SECRET = ENV['CONSUMER_SECRET'] || Settings.twitter.consumer_secret
#CONSUMER_KEY = ""
#CONSUMER_SECRET = ""

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :withings,
    CONSUMER_KEY,
    CONSUMER_SECRET,
    display: 'popup'
end

