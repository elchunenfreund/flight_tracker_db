require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubi"
require "redcarpet"
require "yaml"
require "bcrypt"

require_relative "database_persistence"

root = File.expand_path("..", __FILE__)

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

before do
  @storage = DatabasePersistence.new
end

get "/" do
  @flights = @storage.flights
  erb :flights
end

get "/flights/add" do
  @airlines = @storage.airlines
  @airports = @storage.airports

  erb :form
end

post '/flight/details' do
  if params[:origin] == params[:destination]
    session[:message] = "You don't really want to take a flight that will arrive at the same boring place you left from, or do you?"
    redirect "/flights/add"
  end

  @storage.add_new_flight(session, params[:airline], params[:number], params[:origin], params[:destination], params[:hour].to_i, params[:minute].to_i, params[:meridiem])

  session[:message] = "Your details have been saved."

  erb :details
end

post '/flights/add' do
  flights = @storage.flights
  flight_names = flights.keys
  if flight_names.include?(params[:flightname])
    session[:message] = "You already have a flight with this name saved."
    redirect "/flights/add"
  else
    @storage.save_flight(params[:flightname], session[:airline], session[:number], session[:origin], session[:destination], session[:time])

    session.clear
    session[:message] = "Your flight has been saved."
    redirect "/"
  end
end
