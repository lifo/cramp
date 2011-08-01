class HomeAction < Cramp::Action
  <% if active_record? -%>use_fiber_pool do |pool|
    # Checkin database connection after each callback
    pool.generic_callbacks << proc { ActiveRecord::Base.clear_active_connections! }
  end

  <% end %>def start
    render "Hello World!"
    finish
  end
end
