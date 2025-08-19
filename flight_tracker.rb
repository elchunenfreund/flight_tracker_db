require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubi"
require "redcarpet"
require "yaml"
require "bcrypt"

root = File.expand_path("..", __FILE__)

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

def airlines
  YAML.load_file("airlines.yml")["airlines"]
end

def airports
  YAML.load_file("airports.yml")["airport_codes"]
end

get "/" do
  @flights = YAML.load_file("flights.yml")
  puts @flights.inspect
  erb :flights
end

get "/flights/add" do
  @airlines = airlines
  @airports = airports

  erb :form
end

post '/flight/details' do
  if params[:origin] == params[:destination]
    session[:message] = "You don't really want to take a flight that will arive at the same boring place you left from, or do you?"
    redirect "/flights/add"
  end

  session[:airline] = params[:airline]
  session[:number] = params[:number]
  session[:origin] = params[:origin]
  session[:destination] = params[:destination]
  session[:hour] = "#{"%02d" % params[:hour]}"
  session[:minute] = "#{"%02d" % params[:minute]}"
  session[:meridiem] = params[:meridiem]
  session[:time] = "#{session[:hour]}:#{session[:minute]} #{session[:meridiem]}"

  session[:message] = "Your details have been saved."

  erb :details
end

post '/flights/add' do
  flights = YAML.load_file("flights.yml")
  flight_names = flights.keys
  if flight_names.include?(params[:flightname])
    session[:message] = "You allready have a flight with this name saved."
    redirect "/flights/add"
  else
    flightname = params[:flightname]
    flights[flightname] = { airline: session[:airline],
                            number: session[:number],
                            origin: session[:origin],
                            destination: session[:destination],
                            time: session[:time]  }

    File.open("flights.yml", 'w') do |f|
      f.write flights.to_yaml
    end

    session.clear
    session[:message] = "Your flight has been saved."
    redirect "/"
  end
end
