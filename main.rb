require 'rubygems'
require 'sinatra'

set :sessions, true

POCKET = 1000
helpers do
  def calculate_total(cards)
    arr = cards.map { |e| e[1] }

      total = 0
      arr.each do |value|
        if value == "A"
          total += 11
        elsif value.to_i == 0
        total += 10
        else
          total += value.to_i
        end
      end
  # correct for many aces
    arr.select{|e| e == "A"}.count.times do
      break if total <= 21
        total -= 10
      end
  
    total
  end

  def card_image(card)
    suit = case card[0]
    when 'H' then 'hearts'
    when 'D' then 'diamonds'
    when 'C' then 'clubs'
    when 'S' then 'spades'
  end 

  value = card[1]
  if ['J','Q', 'K', 'A'].include?(value)
    value = case card[1]
      when 'J' then 'jack'
      when 'Q' then 'queen'
      when 'K' then 'king'
      when 'A' then 'ace'
    end
  end

"<img src='/images/cards/#{suit}_#{value}.jpg'>"
end

end

before do
  @show_hit_or_stay_buttons = true
end 

get "/" do
  erb:template
end

post "/name" do
  if params[:name] == ""
  	@error = "Please name can't be empty"
  	erb:template
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
    @error = "Your bet must be lower than your pocket"
    erb:bet
  	
  elsif params[:bet] == ""
    @error = "Please fill in your bet"
  	 erb:bet	
  	
  else
    session[:bet] = params[:bet]
    redirect "/game"
  end
end
 
get "/game" do
  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3','4', '5', '6', '7', '8','9', '10', 'A', 'J', 'Q', 'K', ]
  # here we store the deck of cards in a session. Note that we have it shuffle ready to be dealt
  session[:deck] = suits.product(values).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  erb:game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) > 21
    @error = "Sorry You are busted."
    @show_hit_or_stay_buttons = false
  end
  erb:game
end

post '/game/player/stay' do
  @success = "you have chosen to stay"
  @show_hit_or_stay_buttons = false
  erb :game
end
