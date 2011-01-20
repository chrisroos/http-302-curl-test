require 'rubygems'
require 'sinatra'
require 'haml'

get '/' do
  haml :index
end

post '/collection' do
  redirect '/added'
end

get '/added' do
  'item was added to the collection'
end

__END__
@@ index
%h1 Test form
%form{:action => '/collection', :method => 'post'}
  %input{:type => 'text', :name => 'foo'}
  %input{:type => 'submit', :value => 'Go ahead, submit me'}