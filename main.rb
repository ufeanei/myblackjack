require 'rubygems'
require 'sinatra'

set :sessions, true

get "/" do
	erb:template
end


get "/home" do
	"just show this on home"
end