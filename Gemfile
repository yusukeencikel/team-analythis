source "https://rubygems.org"

gem "rails", "~> 7.2.0.beta2"
gem "pg", "~> 1.1"
gem "puma", "~> 6.4"
gem "image_processing", "~> 1.2"
gem "propshaft"
gem "jbuilder"
gem "cssbundling-rails"
gem "kamal", "~> 2.0"
gem "bootstrap", "~> 5.3"
gem "google-cloud-vision", "~> 1.2"
gem "google-cloud-storage", "~> 1.3"
gem "dotenv-rails"
gem "mini_magick"
gem "roo", "~> 2.10"
gem "csv"
gem "kaminari"
gem "activerecord-session_store"
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "thruster", require: false
gem "tailwindcss-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", "~> 1.9", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rails-omakase", require: false
  gem "brakeman", require: false
  gem "annotate"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

# Windows-specific gems
gem "wdm", "~> 0.1.1", platform: :mswin
