source 'https://rubygems.org'

gem 'traject', git: 'https://github.com/traject/traject', ref: '70890a6a2b6a173ed67ab710b009e0abb82ee2e6'
gem 'traject-marc4j_reader', platform: :jruby

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec'
end

gem 'http'
gem 'i18n'
gem 'manticore', platform: :jruby
gem 'rake'
gem 'stanford-mods'

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano'
end
