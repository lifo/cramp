require './application'

# bundle exec thin --max-persistent-conns 1024 -V -R config.ru start
run <%= app_const %>.routes
