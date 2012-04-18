source 'http://rubygems.org'

gemspec

gem 'cramp', :path => File.dirname(__FILE__)

group :development do
  gem 'rake'
  gem 'minitest'
end

group :test do
  gem 'turn'
  gem 'http_router'
end

group :example do
  gem 'activerecord'
  gem 'mysql2', '~> 0.2.11'

  gem 'em-http-request'

  gem 'thin', '~> 1.2.11'

  gem 'yajl-ruby', :require => 'yajl'

  gem 'http_router'
  gem 'erubis'

  gem 'async-rack'
  gem 'async_sinatra'

  platforms :mri_19 do
    gem 'rainbows'
    gem "ruby-debug19", :require => "ruby-debug" unless RUBY_VERSION > "1.9.2"
    gem 'em-synchrony'
  end

  platforms :rbx do
    # gem 'em-synchrony'
  end
end
