CREATE TABLE airlines(
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL
);

CREATE TABLE airports(
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL
);

CREATE TABLE flights(
  id serial PRIMARY KEY,
  flight_name text NOT NULL,
  airline_id integer REFERENCES airlines(id) NOT NULL,
  flight_number integer NOT NULL,
  origin_id integer REFERENCES airports(id) NOT NULL,
  destination_id integer REFERENCES airports(id) NOT NULL,
  time text NOT NULL
);
