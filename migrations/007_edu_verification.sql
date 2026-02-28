ALTER TABLE users
  ADD COLUMN IF NOT EXISTS student_email TEXT,
  ADD COLUMN IF NOT EXISTS pending_student_email TEXT,
  ADD COLUMN IF NOT EXISTS student_verification_code TEXT,
  ADD COLUMN IF NOT EXISTS student_verification_expires_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS is_student_verified BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS verified_school_name TEXT,
  ADD COLUMN IF NOT EXISTS student_verified_at TIMESTAMPTZ;
