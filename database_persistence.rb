require "pg"

class DatabasePersistence
  def initialize
    @db = PG.connect(dbname: "flight_tracker")
  end

  def airlines
    result = @db.exec_params("SELECT name FROM airlines")
    result.values.flatten
  end

  def airports
    @db.exec_params("SELECT name FROM airports").values.flatten
  end

  def flights
    sql = <<~SQL
      SELECT
          f.flight_name,
          al.name AS "Airline",
          f.flight_number AS "Flight Number",
          orig.name AS "Origin",
          dest.name AS "Destination",
          f.time AS "Time"
      FROM flights f
      JOIN airlines al ON f.airline_id = al.id
      JOIN airports orig ON f.origin_id = orig.id
      JOIN airports dest ON f.destination_id = dest.id;
    SQL
    result = @db.exec_params(sql)
    flight_hash = {}
    result.each do |tuple|
      flight_hash[tuple['flight_name']] =
                              {
                              airline: tuple['Airline'],
                              flight_number: tuple['Flight Number'],
                              origin: tuple['Origin'],
                              destination: tuple['Destination'],
                              time: tuple['Time']
                            }
    end
    flight_hash
  end

  def save_flight(flight_name, airline, flight_number, orig, dest, time)
    airline_sql = "SELECT id FROM airlines WHERE name = $1"
    airport_sql = "SELECT id FROM airports WHERE name = $1"

    airline_id = @db.exec_params(airline_sql, [airline])[0]['id'].to_i
    origin_id  = @db.exec_params(airport_sql, [orig])[0]['id'].to_i
    destination_id = @db.exec_params(airport_sql, [dest])[0]['id'].to_i

    insert_sql = <<~SQL
      INSERT INTO flights (flight_name, airline_id, flight_number, origin_id, destination_id, time)
      VALUES ($1, $2, $3, $4, $5, $6);
    SQL

    @db.exec_params(insert_sql, [flight_name, airline_id, flight_number, origin_id, destination_id, time])
  end

  def update_flight(flight_name, airline, flight_number, orig, dest, time)
    airline_sql = "SELECT id FROM airlines WHERE name = $1"
    airport_sql = "SELECT id FROM airports WHERE name = $1"

    airline_id = @db.exec_params(airline_sql, [airline])[0]['id'].to_i
    origin_id  = @db.exec_params(airport_sql, [orig])[0]['id'].to_i
    destination_id = @db.exec_params(airport_sql, [dest])[0]['id'].to_i

    delete_sql = "DELETE FROM flights WHERE flight_name = $1"
    @db.exec_params(delete_sql, [flight_name])
    insert_sql = <<~SQL
      INSERT INTO flights (flight_name, airline_id, flight_number, origin_id, destination_id, time)
      VALUES ($1, $2, $3, $4, $5, $6);
    SQL

    @db.exec_params(insert_sql, [flight_name, airline_id, flight_number, origin_id, destination_id, time])
  end

  def delete_flight(flight_name)
    sql = "DELETE FROM flights WHERE flight_name = $1"
    @db.exec_params(sql, [flight_name])
  end
end
