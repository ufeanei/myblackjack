require 'rubygems'
require 'sinatra'

set :sessions, true

POCKET = 1000


get "/" do
  erb:template
end

post "/name" do
  if params[:name] == ""
  	@error = "Please name can't be empty"
  	redirect "/"
  else
    session[:name] = params[:name]
    redirect "/newbet"
  end
end


get "/newbet" do
  @your_pocket = POCKET
  erb:bet	
end

post "/bet" do
  
  if params[:bet].to_i > POCKET
    redirect "/newbet"
  	@error = "Your bet must be lower than your pocket"
  elsif params[:bet] == ""
  	 redirect "/newbet"	
  	@error = "Please fill in your bet"
  else
    session[:bet] = params[:bet]
    redirect "/game"
  end
end
 
get "/game" do
  erb:game
end