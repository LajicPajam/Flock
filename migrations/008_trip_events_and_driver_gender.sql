ALTER TABLE users
ADD COLUMN IF NOT EXISTS gender TEXT;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'users_gender_check'
  ) THEN
    ALTER TABLE users
    ADD CONSTRAINT users_gender_check
    CHECK (gender IS NULL OR gender IN ('male', 'female'));
  END IF;
END $$;

ALTER TABLE trips
ADD COLUMN IF NOT EXISTS event_category TEXT;

ALTER TABLE trips
ADD COLUMN IF NOT EXISTS event_name TEXT;
