require 'rubygems'

$: << File.join(File.dirname(__FILE__), "lib")
require 'cramp/model'

Cramp::Model.init(:username => 'root', :database => 'arel_development')

class User < Cramp::Model::Base
  attribute :id, :type => Integer, :primary_key => true
  attribute :name

  validates_presence_of :name
end

EM.run do
  user = User.new

  user.save do |status|
    if status.success?
      puts "WTF!"
    else
      puts "Oops. Found errors : #{user.errors.inspect}"

      user.name = 'Lush'
      user.save

      User.where(User[:name].eq('Lush')).all {|users| puts users.inspect }
    end
  end

  # u.name = 'fifo'
  # 
  # u.save do
  #   u.name = 'ha'
  #   u.save
  # end

  # x = User.where(User[:name].eq('fifo'))
  # x.each {|u| puts u.inspect }
  # x.all {|users| puts users.inspect }

  EM::Timer.new(0.05) { EM.stop }
end

