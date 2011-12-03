source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

gem 'robut', :git => 'git://github.com/substantial/robut.git', 
  :ref => '37de65af7c42ea691f3e76e8952a5821b8170be0'

gem 'rdio', '0.0.91' # .92 is horked
gem 'sinatra'
gem 'thin'

group :development do
  gem "rspec"
  gem "bundler", "~> 1.0.0"
  gem "jeweler", "~> 1.6.4"
  gem "rcov", ">= 0"
  gem 'highline'
  gem 'guard'
  gem 'guard-rspec'
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'cucumber'
end

group :test do
  gem 'rack-test'

end
