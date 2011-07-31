require 'test_helper'

class CallbackTest < Cramp::TestCase

  class CallbackController < Cramp::Action
    cattr_accessor :logs
    cattr_accessor :was_called
    self.logs = []

    before_start :check_id

    def check_id
      if params[:id] !~ /\d+/
        halt 500, {'Content-Type' => 'text/plain'}, "Invalid ID"
      else
        yield
      end
    end

    on_start :send_square
    on_finish :write_logs
    on_new_data :push_data

    def send_square
      number = params[:id].to_i

      render (number * number).to_s
      finish
    end

    def write_logs
      self.logs << params[:id]
    end

    def push_data(params)
      #is just a simple mock
      self.was_called = true
    end
  end

  App = HttpRouter.new do
    add('/:id').to(CallbackController)
  end

  def app
    App
  end

  def test_before_start_halt
    get '/bad' do |status, headers, body|
      assert_equal 500, status
      assert_equal 'text/plain', headers['Content-Type']
      assert_equal 'Invalid ID', body

      EM.stop
    end
  end

  def test_on_start_callback
    get_body_chunks '/4' do |chunks|
      assert_equal "16", chunks[0]
    end
  end

  def test_on_finish_callback
    get_body_chunks '/4'
    assert_equal ['4'], CallbackController.logs
  end

  def test_on_new_data_callback
    assert_equal nil, CallbackController.was_called
    CallbackController.push_new_data
    assert_equal true, CallbackController.was_called
  end
end
