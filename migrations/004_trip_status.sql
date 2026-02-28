ALTER TABLE trips
ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'open';

ALTER TABLE trips
DROP CONSTRAINT IF EXISTS trips_status_check;

ALTER TABLE trips
ADD CONSTRAINT trips_status_check
CHECK (status IN ('open', 'full', 'cancelled', 'completed'));

ALTER TABLE trips
DROP CONSTRAINT IF EXISTS trips_seats_available_check;

ALTER TABLE trips
ADD CONSTRAINT trips_seats_available_check
CHECK (seats_available >= 0);

UPDATE trips
SET status = CASE
  WHEN status = 'cancelled' THEN 'cancelled'
  WHEN seats_available = 0 THEN 'full'
  ELSE 'open'
END;
