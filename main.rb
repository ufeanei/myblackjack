require 'rubygems'
require 'sinatra'

set :sessions, true

POCKET = 1000

get "/" do
	erb:template
	
end

post "/name" do
	session[:name] = params[:name]
	redirect "/newbet"
end


get "/newbet" do
	 @your_pocket = POCKET
	erb:bet	
end

post "/bet" do
  
  if params[:bet].to_i > POCKET
  	@error = "Your bet must be lower than your pocket"
  	redirect "/newbet"
  else
    session[:bet] = params[:bet]
    redirect "/game"
  end
end
 
 get "/game" do
 	erb:game
 end