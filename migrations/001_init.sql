CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  profile_photo_url TEXT NOT NULL,
  is_driver BOOLEAN NOT NULL DEFAULT FALSE,
  car_make TEXT,
  car_model TEXT,
  car_color TEXT,
  car_plate_state TEXT,
  car_plate_number TEXT,
  car_description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS trips (
  id SERIAL PRIMARY KEY,
  driver_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  origin_city TEXT NOT NULL CHECK (origin_city IN (
    'provo_ut',
    'logan_ut',
    'salt_lake_city_ut',
    'rexburg_id',
    'tempe_az'
  )),
  destination_city TEXT NOT NULL CHECK (destination_city IN (
    'provo_ut',
    'logan_ut',
    'salt_lake_city_ut',
    'rexburg_id',
    'tempe_az'
  )),
  departure_time TIMESTAMPTZ NOT NULL,
  seats_available INTEGER NOT NULL CHECK (seats_available > 0),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ride_requests (
  id SERIAL PRIMARY KEY,
  trip_id INTEGER NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  rider_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (trip_id, rider_id)
);

CREATE TABLE IF NOT EXISTS messages (
  id SERIAL PRIMARY KEY,
  trip_id INTEGER NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  sender_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  message_text TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
