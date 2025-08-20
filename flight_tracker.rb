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

get "/flights/:flight_name/edit" do
  @airlines = @storage.airlines
  @airports = @storage.airports
  erb :edit
end

post "/flights/:flight_name/edit" do
  flights = @storage.flights
  flight_names = flights.keys
  time = "%02d:%02d %s" % [params[:hour], params[:minute], params[:meridiem]]
  @storage.update_flight(params[:flight_name], params[:airline], params[:flight_number], params[:origin], params[:destination], time)

  session.clear
  session[:message] = "Your flight has been updated."
  redirect "/"
end

delete "/flights/:flight_name/delete" do
  session[:message] = "The flight named #{params[:flight_name]} has been Deleted"
  @storage.delete_flight(params[:flight_name])
  redirect "/"
end

post '/flight/details' do # Display flight being added.
  if params[:origin] == params[:destination]
    session[:message] = "You don't really want to take a flight that will arrive at the same boring place you left from, or do you?"
    redirect "/flights/add"
  end

  session[:airline] = params[:airline]
  session[:flight_number] = params[:flight_number]
  session[:origin] = params[:origin]
  session[:destination] = params[:destination]
  time = "%02d:%02d %s" % [params[:hour], params[:minute], params[:meridiem]]
  session[:time] = time
  session[:message] = "Your details have been saved."

  erb :details
end

post '/flights/add' do
  flights = @storage.flights
  flight_names = flights.keys
  if flight_names.include?(params[:flight_name])
    session[:message] = "You already have a flight with this name saved."
    redirect "/flights/add"
  else
    @storage.save_flight(params[:flight_name], session[:airline], session[:flight_number], session[:origin], session[:destination], session[:time])

    session.clear
    session[:message] = "Your flight has been saved."
    redirect "/"
  end
end
