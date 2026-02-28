ALTER TABLE trips
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'upcoming'
  CHECK (status IN ('upcoming', 'completed', 'cancelled'));
