require File.join(File.dirname(__FILE__), "../vendor/gems/environment")

$: << File.join(File.dirname(__FILE__), "../lib")

require 'cramp/controller'
require 'cramp/model'

Cramp::Model.init(:username => 'root', :database => 'arel_development')

class User < Cramp::Model::Base
  attribute :id, :type => Integer, :primary_key => true
  attribute :name

  validates_presence_of :name
end

class UsersController < Cramp::Controller::Base
  before_start :verify_id, :find_user

  def verify_id
    if params[:id].nil? || params[:id] !~ /\d+/
      halt 500, {}, "Bad Request"
    else
      yield
    end
  end

  def find_user
    User.where(User[:id].eq(params[:id])).first do |user|
      if @user = user
        yield
      else
        halt 404, {}, "User not found"
      end
    end
  end

  # Sends a space ( ' ' ) to the client for keeping the connection alive. Default : Every 15 seconds
  keep_connection_alive :every => 1

  # Polls every 1 second by default
  periodic_timer :poll_user

  def poll_user
    User.where(User[:id].eq(@user.id)).first do |user|
      if @user.name != user.name
        render "User's name changed from #{@user.name} to #{user.name}"
        finish
      end
    end
  end

end

routes = Usher::Interface.for(:rack) do
  add('/users/:id').to(UsersController)
end

Rack::Handler::Thin.run routes, :Port => 3000
