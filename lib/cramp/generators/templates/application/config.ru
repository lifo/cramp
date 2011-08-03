require './application'
<%= app_const %>.initialize!

# Development middlewares
if <%= app_const %>.env == 'development'
  require 'async-rack'
  use AsyncRack::CommonLogger
end

# Running thin :
#
#   bundle exec thin --max-persistent-conns 1024 -R config.ru start
#
# Vebose mode :
#
#   Very useful when you want to view all the data being sent/received by thin
#
#   bundle exec thin --max-persistent-conns 1024 -R -V config.ru start
#
run <%= app_const %>.routes
