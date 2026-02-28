ALTER TABLE trips
ADD COLUMN IF NOT EXISTS meeting_spot TEXT;

ALTER TABLE trips
DROP CONSTRAINT IF EXISTS trips_status_check;

ALTER TABLE trips
ADD CONSTRAINT trips_status_check
CHECK (status IN ('open', 'full', 'cancelled', 'completed'));

CREATE TABLE IF NOT EXISTS notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  trip_id INTEGER REFERENCES trips(id) ON DELETE CASCADE,
  request_id INTEGER REFERENCES ride_requests(id) ON DELETE CASCADE,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
