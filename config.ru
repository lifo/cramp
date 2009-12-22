# thin -R config.ru --max-persistent-conns 1024 start
require 'home_controller'

routes = Usher::Interface.for(:rack) do
  add('/(:password)').to(HomeController)
end

use Rack::ShowExceptions
run routes
