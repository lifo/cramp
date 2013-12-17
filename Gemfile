source 'http://rubygems.org'

gemspec

gem 'cramp', :path => File.dirname(__FILE__)

group :test do
  gem 'turn'
  gem 'http_router'
  gem 'minitest'
end

group :example do

  gem 'http_router'
  gem 'erubis'
  gem 'async-rack'
  gem 'async_sinatra'
  gem 'em-http-request'
  gem 'em-synchrony'
  gem 'activerecord', '~> 3.0.9'

  platforms :mri_19 do
    gem 'rainbows'
    gem "ruby-debug19", :require => "ruby-debug" unless RUBY_VERSION > "1.9.2"
    gem 'mysql2', '~> 0.2.11'
    gem 'thin', '~> 1.2.11'
    gem 'yajl-ruby', :require => 'yajl'
  end
end
