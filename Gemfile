source "https://rubygems.org"

gem "rails", "~> 8.0.1"
gem "puma", ">= 5.0"
gem "pg"

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

gem "config"
gem "circuitbox", github: "yammer/circuitbox"
gem "faraday"
gem "faraday_middleware"
gem "strong_migrations"
gem "dry-initializer"
gem "dry-monads"
gem "dry-validation"
gem "active_model_serializers"

group :development, :test do
  gem "dotenv"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "database_cleaner"
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "webmock"
  gem "vcr", require: false
  gem "factory_bot_rails", require: false
  gem "simplecov", require: false
end
