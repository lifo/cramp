require "rubygems"
require "bundler"
Bundler.setup(:default, :example)

require 'cramp'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "em_mysql2", :username => 'root', :database => "arel_development", :pool => 100)

class User < ActiveRecord::Base
  validates_presence_of :name
end

class FullFibersController < Cramp::Action
  use_fiber_pool do |pool|
    # Called everytime after a fiber is done a callback
    pool.generic_callbacks << proc { ActiveRecord::Base.clear_active_connections! }
  end

  on_start :init_last_user
  periodic_timer :watch_out_for_new_user

  def init_last_user
    @last_user = User.last
  end

  def watch_out_for_new_user
    user = User.last

    unless user == @last_user
      render "Finally a new user ! -> #{user.id}:#{user.name}"
      finish
    end
  end
end

# bundle exec thin -V -R examples/fibers/active_record.ru start
# bundle exec rainbows -E deployment -c examples/rainbows.conf examples/fibers/active_record.ru
run FullFibersController
