require 'rubygems'
require 'sinatra'

set :sessions, true

POCKET = 1000
BLACKJACK = 21
DEALERMINT = 17
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
      break if total <= BLACKJACK
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

def winner!(msg)
  @play_again = true
  @show_hit_or_stay_buttons = false
  @success = "<strong>#{session[:name]} wins!</strong> #{msg}"
end

def loser!(msg)
  @play_again = true
  @show_hit_or_stay_buttons = false
  @error = "<strong>#{session[:name]} losses.</strong> #{msg}"
end 
def tie!(msg)
  @play_again = true
  @show_hit_or_stay_buttons = false
  @success = "<strong>It's a tie!</strong> #{msg}"
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

  session[:turn] = session[:name]

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
  player_total = calculate_total(session[:player_cards])
  if player_total  == BLACKJACK
    winner!("#{session[:name]} hit blackjack")
  elsif player_total > BLACKJACK
    loser!("Sorry #{session[:name]}, You are busted at #{player_total}.")
  end
  erb:game
end

post '/game/player/stay' do
  @success = "#{session[:name]},you have chosen to stay"
  @show_hit_or_stay_buttons = false
  redirect "/game/dealer"
end

get "/game/dealer" do
  session[:turn] = "dealer"

  @show_hit_or_stay_buttons = false
  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == BLACKJACK
    loser!("Sorry #{session[:name]}, You lost, dealer hits blackjack.")
  elsif dealer_total > BLACKJACK
    winner!("Dealer busted at #{dealer_total}.")
  elsif dealer_total >= DEALERMINT
    redirect "/game/compare"
  else
    @show_dealer_hit_button = true
  end
  erb:game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    loser!("#{session[:name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.") 
  elsif player_total > dealer_total
    winner!("#{session[:name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  else
    tie!("#{session[:name]}, your total is #{player_total}, and the dealer total is #{dealer_total} so it is a tie")
  end
  erb:game
end

get "/game_over" do
  erb:game_over
end
    
