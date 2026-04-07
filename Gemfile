source "https://rubygems.org"

gem "rails", "~> 8.0.3"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "bcrypt", "~> 3.1.7"
gem "jwt", "~> 2.9"
gem "rack-cors"
gem "hexapdf"
gem "active_model_serializers", "~> 0.10"
gem "dotenv-rails", groups: [:development, :test]
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end