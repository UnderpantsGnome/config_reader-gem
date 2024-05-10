source "http://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in config_reader.gemspec
gemspec

gem "sekrets", github: "UnderpantsGnome/sekrets", branch: "ruby-3-2-support"

group :development do
  gem "prettier", "~> 4.0"
  gem "standard", "~> 1.29"
end
