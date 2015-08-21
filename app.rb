require 'sinatra/base'
require './routes/company'


class App < Sinatra::Base
  use Routes::Company

  set :bind, '0.0.0.0'

end


