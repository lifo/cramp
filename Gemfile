source 'http://rubygems.org'

gemspec

gem 'crampy', :path => File.dirname(__FILE__)


group :test do
  gem 'turn'
  gem 'minitest', "~>4.7.3" # turn is not supported in 5+
  gem 'http_router'
end

group :example do
  gem 'activerecord'
  gem 'mysql2'

  gem 'em-http-request'

  gem 'thin'

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
