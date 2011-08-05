require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "em_mysql2", :username => 'root', :database => "arel_development", :pool => 100)

class User < ActiveRecord::Base
  validates_presence_of :name
end

class LongQueryController < Cramp::Action
  use_fiber_pool do |pool|
    # Called everytime after a fiber is done a callback
    pool.generic_callbacks << proc { ActiveRecord::Base.clear_active_connections! }
  end

  on_start :run_srsly_long_query

  def run_srsly_long_query
    result = User.connection.execute('select 1, sleep(1)')
    render "Result : #{result.first}"
    finish
  end
end

# bundle exec thin -V -R examples/fibers/long_ar_query.ru start
# bundle exec rainbows -E deployment -c examples/rainbows.conf examples/fibers/long_ar_query.ru
run LongQueryController

# Pool size 50
# [lifo@null cramp (master)]$ ab -n 50 -c 50 http://0.0.0.0:3000/
# Time taken for tests:   1.044 seconds
# Requests per second:    48.93 [#/sec] (mean)

# Pool size 10
# [lifo@null cramp (master)]$ ab -n 50 -c 50 http://0.0.0.0:3000/
# Time taken for tests:   5.163 seconds
# Requests per second:    9.68 [#/sec] (mean)
