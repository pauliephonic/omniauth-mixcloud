require 'bundler/setup'
require 'sinatra/base'
require 'omniauth-mixcloud'

class App < Sinatra::Base
  get '/' do
    redirect '/auth/mixcloud'
  end

  get '/auth/:provider/callback' do
    content_type 'application/json'
    MultiJson.encode(request.env)
  end
  
  get '/auth/failure' do
    content_type 'application/json'
    MultiJson.encode(request.env)
  end
end

use Rack::Session::Cookie

use OmniAuth::Builder do
  provider :mixcloud, 'wpLF5wDyDUQYQJnrFY', 'jnu8tAF89tecB99ztdautCUduWXnQTUj'#, :scope => 'non-expiring'
end

run App.new
