class DatabasePersistence
  # def initilaize
  #   @airlines = airlines
  #   @flights = flights
  #   @airports = airports
  # end

  def airlines
    YAML.load_file("airlines.yml")["airlines"]
  end

  def airports
    YAML.load_file("airports.yml")["airport_codes"]
  end

  def flights
    YAML.load_file("flights.yml") || {}
  rescue Errno::ENOENT
    {}  # file doesn't exist yet
  end


  def add_new_flight(session, airline, flight_number, origin, destination, hour, minute, meridiem)
    session[:airline] = airline
    session[:number] = flight_number
    session[:origin] = origin
    session[:destination] = destination
    session[:hour] = "%02d" % hour
    session[:minute] = "%02d" % minute
    session[:meridiem] = meridiem
    session[:time] = "#{session[:hour]}:#{session[:minute]} #{session[:meridiem]}"
  end

  def save_flight(flightname, airline, number, origin, destination, time)
    current_flights = flights           # load fresh from file
    current_flights[flightname] = {     # add new flight
      airline: airline,
      number: number,
      origin: origin,
      destination: destination,
      time: time
    }

    File.open("flights.yml", "w") do |f|
      f.write current_flights.to_yaml   # write merged data
    end
  end
end
