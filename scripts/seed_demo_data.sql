-- Demo-only local seed data for the Flock prototype.
-- Safe to run multiple times: users upsert, related rows avoid duplicates.

-- Ensure the newer schema pieces exist.
\i migrations/002_driver_profiles.sql
\i migrations/003_reviews.sql
\i migrations/004_trip_status.sql
\i migrations/005_trip_history_notifications.sql
\i migrations/006_trip_exact_locations.sql

-- Users
INSERT INTO users (
  name,
  email,
  password_hash,
  phone_number,
  profile_photo_url,
  is_driver,
  car_make,
  car_model,
  car_color,
  car_plate_state,
  car_plate_number,
  car_description
)
VALUES
  (
    'Brad Carter',
    'seed+brad@flock.local',
    '$2b$10$kq9HLM8pRWKEGDPbg2T/2eRR38v3z.E97ExEFso8HkekCUIyta7u6',
    '8015550101',
    'https://placehold.co/200x200/png?text=BC',
    TRUE,
    'Toyota',
    'Highlander',
    'Blue',
    'UT',
    'BCR-101',
    'Roof box and extra trunk space.'
  ),
  (
    'Tessa Kim',
    'seed+tessa@flock.local',
    '$2b$10$kq9HLM8pRWKEGDPbg2T/2eRR38v3z.E97ExEFso8HkekCUIyta7u6',
    '3855550102',
    'https://placehold.co/200x200/png?text=TK',
    TRUE,
    'Honda',
    'CR-V',
    'Silver',
    'UT',
    'TKM-202',
    'Usually leaves exactly on time.'
  ),
  (
    'Noah Reed',
    'seed+noah@flock.local',
    '$2b$10$kq9HLM8pRWKEGDPbg2T/2eRR38v3z.E97ExEFso8HkekCUIyta7u6',
    '2085550103',
    'https://placehold.co/200x200/png?text=NR',
    TRUE,
    'Subaru',
    'Outback',
    'Green',
    'ID',
    'NRD-303',
    'Can fit backpacks and one suitcase.'
  ),
  (
    'Emma Lopez',
    'seed+emma@flock.local',
    '$2b$10$kq9HLM8pRWKEGDPbg2T/2eRR38v3z.E97ExEFso8HkekCUIyta7u6',
    '7205550104',
    'https://placehold.co/200x200/png?text=EL',
    FALSE,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
  ),
  (
    'Josh Patel',
    'seed+josh@flock.local',
    '$2b$10$kq9HLM8pRWKEGDPbg2T/2eRR38v3z.E97ExEFso8HkekCUIyta7u6',
    '6025550105',
    'https://placehold.co/200x200/png?text=JP',
    FALSE,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
  ),
  (
    'Mia Walker',
    'seed+mia@flock.local',
    '$2b$10$kq9HLM8pRWKEGDPbg2T/2eRR38v3z.E97ExEFso8HkekCUIyta7u6',
    '8015550106',
    'https://placehold.co/200x200/png?text=MW',
    FALSE,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
  ),
  (
    'Caleb Stone',
    'seed+caleb@flock.local',
    '$2b$10$kq9HLM8pRWKEGDPbg2T/2eRR38v3z.E97ExEFso8HkekCUIyta7u6',
    '8015550107',
    'https://placehold.co/200x200/png?text=CS',
    TRUE,
    'Ford',
    'Explorer',
    'Black',
    'UT',
    'CAL-707',
    'Usually drives the whole way without long stops.'
  ),
  (
    'Sophie Chen',
    'seed+sophie@flock.local',
    '$2b$10$kq9HLM8pRWKEGDPbg2T/2eRR38v3z.E97ExEFso8HkekCUIyta7u6',
    '3035550108',
    'https://placehold.co/200x200/png?text=SC',
    FALSE,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
  ),
  (
    'Liam Torres',
    'seed+liam@flock.local',
    '$2b$10$kq9HLM8pRWKEGDPbg2T/2eRR38v3z.E97ExEFso8HkekCUIyta7u6',
    '8015550109',
    'https://placehold.co/200x200/png?text=LT',
    FALSE,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
  ),
  (
    'Rachel Young',
    'seed+rachel@flock.local',
    '$2b$10$kq9HLM8pRWKEGDPbg2T/2eRR38v3z.E97ExEFso8HkekCUIyta7u6',
    '6025550110',
    'https://placehold.co/200x200/png?text=RY',
    FALSE,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
  ),
  (
    'Ethan Brooks',
    'seed+ethan@flock.local',
    '$2b$10$kq9HLM8pRWKEGDPbg2T/2eRR38v3z.E97ExEFso8HkekCUIyta7u6',
    '2085550111',
    'https://placehold.co/200x200/png?text=EB',
    TRUE,
    'Chevrolet',
    'Tahoe',
    'White',
    'ID',
    'ETH-111',
    'Good for ski gear and duffel bags.'
  ),
  (
    'Olivia Hart',
    'seed+olivia@flock.local',
    '$2b$10$kq9HLM8pRWKEGDPbg2T/2eRR38v3z.E97ExEFso8HkekCUIyta7u6',
    '7205550112',
    'https://placehold.co/200x200/png?text=OH',
    FALSE,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
  )
ON CONFLICT (email) DO UPDATE SET
  name = EXCLUDED.name,
  password_hash = EXCLUDED.password_hash,
  phone_number = EXCLUDED.phone_number,
  profile_photo_url = EXCLUDED.profile_photo_url,
  is_driver = EXCLUDED.is_driver,
  car_make = EXCLUDED.car_make,
  car_model = EXCLUDED.car_model,
  car_color = EXCLUDED.car_color,
  car_plate_state = EXCLUDED.car_plate_state,
  car_plate_number = EXCLUDED.car_plate_number,
  car_description = EXCLUDED.car_description;

-- Trips
INSERT INTO trips (
  driver_id,
  origin_city,
  destination_city,
  origin_label,
  destination_label,
  origin_latitude,
  origin_longitude,
  destination_latitude,
  destination_longitude,
  departure_time,
  seats_available,
  status,
  meeting_spot,
  notes
)
SELECT
  u.id,
  'provo_ut',
  'tempe_az',
  'Spanish Fork, Utah',
  'Scottsdale, Arizona',
  40.1149,
  -111.6549,
  33.4942,
  -111.9261,
  NOW() + INTERVAL '2 days',
  2,
  'open',
  'Text the driver when you are 10 minutes out.',
  '[seed-demo] Spanish Fork to Scottsdale road trip'
FROM users u
WHERE u.email = 'seed+brad@flock.local'
  AND NOT EXISTS (
    SELECT 1 FROM trips t
    WHERE t.driver_id = u.id
      AND t.notes = '[seed-demo] Spanish Fork to Scottsdale road trip'
  );

INSERT INTO trips (
  driver_id,
  origin_city,
  destination_city,
  origin_label,
  destination_label,
  origin_latitude,
  origin_longitude,
  destination_latitude,
  destination_longitude,
  departure_time,
  seats_available,
  status,
  meeting_spot,
  notes
)
SELECT
  u.id,
  'provo_ut',
  'rexburg_id',
  'Lehi, Utah',
  'Idaho Falls, Idaho',
  40.3916,
  -111.8508,
  43.4917,
  -112.0339,
  NOW() + INTERVAL '1 day',
  3,
  'open',
  'North side of the outlet mall lot.',
  '[seed-demo] Lehi to Idaho Falls'
FROM users u
WHERE u.email = 'seed+tessa@flock.local'
  AND NOT EXISTS (
    SELECT 1 FROM trips t
    WHERE t.driver_id = u.id
      AND t.notes = '[seed-demo] Lehi to Idaho Falls'
  );

INSERT INTO trips (
  driver_id,
  origin_city,
  destination_city,
  origin_label,
  destination_label,
  origin_latitude,
  origin_longitude,
  destination_latitude,
  destination_longitude,
  departure_time,
  seats_available,
  status,
  meeting_spot,
  notes
)
SELECT
  u.id,
  'logan_ut',
  'rexburg_id',
  'Brigham City, Utah',
  'Idaho Falls, Idaho',
  41.5102,
  -112.0155,
  43.4917,
  -112.0339,
  NOW() - INTERVAL '3 days',
  1,
  'completed',
  'Meet by the gas station on Main.',
  '[seed-demo] Brigham City to Idaho Falls completed'
FROM users u
WHERE u.email = 'seed+noah@flock.local'
  AND NOT EXISTS (
    SELECT 1 FROM trips t
    WHERE t.driver_id = u.id
      AND t.notes = '[seed-demo] Brigham City to Idaho Falls completed'
  );

INSERT INTO trips (
  driver_id,
  origin_city,
  destination_city,
  origin_label,
  destination_label,
  origin_latitude,
  origin_longitude,
  destination_latitude,
  destination_longitude,
  departure_time,
  seats_available,
  status,
  meeting_spot,
  notes
)
SELECT
  u.id,
  'rexburg_id',
  'salt_lake_city_ut',
  'Rexburg, Idaho',
  'Ogden, Utah',
  43.8260,
  -111.7897,
  41.2230,
  -111.9738,
  NOW() + INTERVAL '4 days',
  0,
  'full',
  'Student center parking lot.',
  '[seed-demo] Rexburg to Ogden full'
FROM users u
WHERE u.email = 'seed+noah@flock.local'
  AND NOT EXISTS (
    SELECT 1 FROM trips t
    WHERE t.driver_id = u.id
      AND t.notes = '[seed-demo] Rexburg to Ogden full'
  );

INSERT INTO trips (
  driver_id,
  origin_city,
  destination_city,
  origin_label,
  destination_label,
  origin_latitude,
  origin_longitude,
  destination_latitude,
  destination_longitude,
  departure_time,
  seats_available,
  status,
  meeting_spot,
  notes
)
SELECT
  u.id,
  'tempe_az',
  'provo_ut',
  'Mesa, Arizona',
  'Orem, Utah',
  33.4152,
  -111.8315,
  40.2969,
  -111.6946,
  NOW() + INTERVAL '5 days',
  2,
  'cancelled',
  'Cancelled trip, no pickup.',
  '[seed-demo] Mesa to Orem cancelled'
FROM users u
WHERE u.email = 'seed+tessa@flock.local'
  AND NOT EXISTS (
    SELECT 1 FROM trips t
    WHERE t.driver_id = u.id
      AND t.notes = '[seed-demo] Mesa to Orem cancelled'
  );

INSERT INTO trips (
  driver_id,
  origin_city,
  destination_city,
  origin_label,
  destination_label,
  origin_latitude,
  origin_longitude,
  destination_latitude,
  destination_longitude,
  departure_time,
  seats_available,
  status,
  meeting_spot,
  notes
)
SELECT
  u.id,
  'provo_ut',
  'tempe_az',
  'Provo, Utah',
  'Amarillo, Texas',
  40.2338,
  -111.6585,
  35.2220,
  -101.8313,
  NOW() + INTERVAL '6 days',
  3,
  'open',
  'Flexible pickup anywhere close to the interstate.',
  '[seed-demo] Provo to Amarillo long haul'
FROM users u
WHERE u.email = 'seed+caleb@flock.local'
  AND NOT EXISTS (
    SELECT 1 FROM trips t
    WHERE t.driver_id = u.id
      AND t.notes = '[seed-demo] Provo to Amarillo long haul'
  );

INSERT INTO trips (
  driver_id,
  origin_city,
  destination_city,
  origin_label,
  destination_label,
  origin_latitude,
  origin_longitude,
  destination_latitude,
  destination_longitude,
  departure_time,
  seats_available,
  status,
  meeting_spot,
  notes
)
SELECT
  u.id,
  'salt_lake_city_ut',
  'tempe_az',
  'Farmington, Utah',
  'Moab, Utah',
  40.9805,
  -111.8874,
  38.5733,
  -109.5498,
  NOW() + INTERVAL '36 hours',
  2,
  'open',
  'Can pick up just off I-80.',
  '[seed-demo] Farmington to Moab'
FROM users u
WHERE u.email = 'seed+caleb@flock.local'
  AND NOT EXISTS (
    SELECT 1 FROM trips t
    WHERE t.driver_id = u.id
      AND t.notes = '[seed-demo] Farmington to Moab'
  );

INSERT INTO trips (
  driver_id,
  origin_city,
  destination_city,
  origin_label,
  destination_label,
  origin_latitude,
  origin_longitude,
  destination_latitude,
  destination_longitude,
  departure_time,
  seats_available,
  status,
  meeting_spot,
  notes
)
SELECT
  u.id,
  'salt_lake_city_ut',
  'rexburg_id',
  'Layton, Utah',
  'Twin Falls, Idaho',
  41.0602,
  -111.9711,
  42.5629,
  -114.4609,
  NOW() + INTERVAL '3 days',
  1,
  'open',
  'Quick pickup near the highway on-ramp.',
  '[seed-demo] Layton to Twin Falls'
FROM users u
WHERE u.email = 'seed+ethan@flock.local'
  AND NOT EXISTS (
    SELECT 1 FROM trips t
    WHERE t.driver_id = u.id
      AND t.notes = '[seed-demo] Layton to Twin Falls'
  );

INSERT INTO trips (
  driver_id,
  origin_city,
  destination_city,
  origin_label,
  destination_label,
  origin_latitude,
  origin_longitude,
  destination_latitude,
  destination_longitude,
  departure_time,
  seats_available,
  status,
  meeting_spot,
  notes
)
SELECT
  u.id,
  'tempe_az',
  'provo_ut',
  'Tempe, Arizona',
  'Flagstaff, Arizona',
  33.4255,
  -111.9400,
  35.1983,
  -111.6513,
  NOW() + INTERVAL '7 days',
  2,
  'open',
  'Text for exact pickup lot after you request.',
  '[seed-demo] Tempe to Flagstaff'
FROM users u
WHERE u.email = 'seed+tessa@flock.local'
  AND NOT EXISTS (
    SELECT 1 FROM trips t
    WHERE t.driver_id = u.id
      AND t.notes = '[seed-demo] Tempe to Flagstaff'
  );

INSERT INTO trips (
  driver_id,
  origin_city,
  destination_city,
  origin_label,
  destination_label,
  origin_latitude,
  origin_longitude,
  destination_latitude,
  destination_longitude,
  departure_time,
  seats_available,
  status,
  meeting_spot,
  notes
)
SELECT
  u.id,
  'rexburg_id',
  'salt_lake_city_ut',
  'Pocatello, Idaho',
  'Downtown Salt Lake City, Utah',
  42.8713,
  -112.4455,
  40.7608,
  -111.8910,
  NOW() - INTERVAL '10 days',
  2,
  'completed',
  'Old completed trip for review history.',
  '[seed-demo] Pocatello to Salt Lake completed'
FROM users u
WHERE u.email = 'seed+ethan@flock.local'
  AND NOT EXISTS (
    SELECT 1 FROM trips t
    WHERE t.driver_id = u.id
      AND t.notes = '[seed-demo] Pocatello to Salt Lake completed'
  );

-- Ride requests
INSERT INTO ride_requests (trip_id, rider_id, message, status)
SELECT
  t.id,
  u.id,
  'I can meet anywhere along I-15 and split gas.',
  'accepted'
FROM trips t
JOIN users u ON u.email = 'seed+emma@flock.local'
WHERE t.notes = '[seed-demo] Spanish Fork to Scottsdale road trip'
ON CONFLICT (trip_id, rider_id) DO UPDATE SET
  message = EXCLUDED.message,
  status = EXCLUDED.status;

INSERT INTO ride_requests (trip_id, rider_id, message, status)
SELECT
  t.id,
  u.id,
  'I only need a lift as far as Farmington if that works.',
  'pending'
FROM trips t
JOIN users u ON u.email = 'seed+josh@flock.local'
WHERE t.notes = '[seed-demo] Lehi to Idaho Falls'
ON CONFLICT (trip_id, rider_id) DO UPDATE SET
  message = EXCLUDED.message,
  status = EXCLUDED.status;

INSERT INTO ride_requests (trip_id, rider_id, message, status)
SELECT
  t.id,
  u.id,
  'Thanks again for the ride last week.',
  'accepted'
FROM trips t
JOIN users u ON u.email = 'seed+mia@flock.local'
WHERE t.notes = '[seed-demo] Brigham City to Idaho Falls completed'
ON CONFLICT (trip_id, rider_id) DO UPDATE SET
  message = EXCLUDED.message,
  status = EXCLUDED.status;

INSERT INTO ride_requests (trip_id, rider_id, message, status)
SELECT
  t.id,
  u.id,
  'I am in Denver and only need a ride as far as Kansas City.',
  'pending'
FROM trips t
JOIN users u ON u.email = 'seed+sophie@flock.local'
WHERE t.notes = '[seed-demo] Provo to Amarillo long haul'
ON CONFLICT (trip_id, rider_id) DO UPDATE SET
  message = EXCLUDED.message,
  status = EXCLUDED.status;

INSERT INTO ride_requests (trip_id, rider_id, message, status)
SELECT
  t.id,
  u.id,
  'I can meet in Cheyenne and get out in eastern Nebraska.',
  'accepted'
FROM trips t
JOIN users u ON u.email = 'seed+liam@flock.local'
WHERE t.notes = '[seed-demo] Provo to Amarillo long haul'
ON CONFLICT (trip_id, rider_id) DO UPDATE SET
  message = EXCLUDED.message,
  status = EXCLUDED.status;

INSERT INTO ride_requests (trip_id, rider_id, message, status)
SELECT
  t.id,
  u.id,
  'Can you grab me near Park City and drop me in Laramie?',
  'accepted'
FROM trips t
JOIN users u ON u.email = 'seed+olivia@flock.local'
WHERE t.notes = '[seed-demo] Farmington to Moab'
ON CONFLICT (trip_id, rider_id) DO UPDATE SET
  message = EXCLUDED.message,
  status = EXCLUDED.status;

INSERT INTO ride_requests (trip_id, rider_id, message, status)
SELECT
  t.id,
  u.id,
  'I just need a seat to Twin Falls if that works.',
  'pending'
FROM trips t
JOIN users u ON u.email = 'seed+rachel@flock.local'
WHERE t.notes = '[seed-demo] Layton to Twin Falls'
ON CONFLICT (trip_id, rider_id) DO UPDATE SET
  message = EXCLUDED.message,
  status = EXCLUDED.status;

INSERT INTO ride_requests (trip_id, rider_id, message, status)
SELECT
  t.id,
  u.id,
  'Happy to chip in for gas and snacks.',
  'accepted'
FROM trips t
JOIN users u ON u.email = 'seed+sophie@flock.local'
WHERE t.notes = '[seed-demo] Pocatello to Salt Lake completed'
ON CONFLICT (trip_id, rider_id) DO UPDATE SET
  message = EXCLUDED.message,
  status = EXCLUDED.status;

-- Messages
INSERT INTO messages (trip_id, sender_id, receiver_id, message_text)
SELECT
  t.id,
  d.id,
  r.id,
  'You can hop in near Cedar City if that is easiest for you.'
FROM trips t
JOIN users d ON d.email = 'seed+brad@flock.local'
JOIN users r ON r.email = 'seed+emma@flock.local'
WHERE t.notes = '[seed-demo] Spanish Fork to Scottsdale road trip'
  AND NOT EXISTS (
    SELECT 1 FROM messages m
    WHERE m.trip_id = t.id
      AND m.message_text = 'You can hop in near Cedar City if that is easiest for you.'
  );

INSERT INTO messages (trip_id, sender_id, receiver_id, message_text)
SELECT
  t.id,
  r.id,
  d.id,
  'Perfect. I can be ready at the freeway exit around 9:30.'
FROM trips t
JOIN users d ON d.email = 'seed+brad@flock.local'
JOIN users r ON r.email = 'seed+emma@flock.local'
WHERE t.notes = '[seed-demo] Spanish Fork to Scottsdale road trip'
  AND NOT EXISTS (
    SELECT 1 FROM messages m
    WHERE m.trip_id = t.id
      AND m.message_text = 'Perfect. I can be ready at the freeway exit around 9:30.'
  );

INSERT INTO messages (trip_id, sender_id, receiver_id, message_text)
SELECT
  t.id,
  d.id,
  r.id,
  'Cheyenne pickup is fine, just text me your exact exit.'
FROM trips t
JOIN users d ON d.email = 'seed+caleb@flock.local'
JOIN users r ON r.email = 'seed+liam@flock.local'
WHERE t.notes = '[seed-demo] Provo to Amarillo long haul'
  AND NOT EXISTS (
    SELECT 1 FROM messages m
    WHERE m.trip_id = t.id
      AND m.message_text = 'Cheyenne pickup is fine, just text me your exact exit.'
  );

INSERT INTO messages (trip_id, sender_id, receiver_id, message_text)
SELECT
  t.id,
  r.id,
  d.id,
  'Perfect, I will be waiting by the gas station there.'
FROM trips t
JOIN users d ON d.email = 'seed+caleb@flock.local'
JOIN users r ON r.email = 'seed+liam@flock.local'
WHERE t.notes = '[seed-demo] Provo to Amarillo long haul'
  AND NOT EXISTS (
    SELECT 1 FROM messages m
    WHERE m.trip_id = t.id
      AND m.message_text = 'Perfect, I will be waiting by the gas station there.'
  );

-- Reviews
INSERT INTO reviews (trip_id, reviewer_id, reviewee_id, rating, comment)
SELECT
  t.id,
  rider.id,
  driver.id,
  5,
  'Easy coordination and exactly on time.'
FROM trips t
JOIN users driver ON driver.email = 'seed+noah@flock.local'
JOIN users rider ON rider.email = 'seed+mia@flock.local'
WHERE t.notes = '[seed-demo] Brigham City to Idaho Falls completed'
ON CONFLICT (trip_id, reviewer_id, reviewee_id) DO UPDATE SET
  rating = EXCLUDED.rating,
  comment = EXCLUDED.comment;

INSERT INTO reviews (trip_id, reviewer_id, reviewee_id, rating, comment)
SELECT
  t.id,
  rider.id,
  driver.id,
  4,
  'Smooth ride and easy pickup coordination.'
FROM trips t
JOIN users driver ON driver.email = 'seed+ethan@flock.local'
JOIN users rider ON rider.email = 'seed+sophie@flock.local'
WHERE t.notes = '[seed-demo] Pocatello to Salt Lake completed'
ON CONFLICT (trip_id, reviewer_id, reviewee_id) DO UPDATE SET
  rating = EXCLUDED.rating,
  comment = EXCLUDED.comment;

INSERT INTO reviews (trip_id, reviewer_id, reviewee_id, rating, comment)
SELECT
  t.id,
  driver.id,
  rider.id,
  5,
  'Very communicative and ready at pickup.'
FROM trips t
JOIN users driver ON driver.email = 'seed+ethan@flock.local'
JOIN users rider ON rider.email = 'seed+sophie@flock.local'
WHERE t.notes = '[seed-demo] Pocatello to Salt Lake completed'
ON CONFLICT (trip_id, reviewer_id, reviewee_id) DO UPDATE SET
  rating = EXCLUDED.rating,
  comment = EXCLUDED.comment;

INSERT INTO reviews (trip_id, reviewer_id, reviewee_id, rating, comment)
SELECT
  t.id,
  driver.id,
  rider.id,
  5,
  'Showed up early and was easy to coordinate with.'
FROM trips t
JOIN users driver ON driver.email = 'seed+noah@flock.local'
JOIN users rider ON rider.email = 'seed+mia@flock.local'
WHERE t.notes = '[seed-demo] Brigham City to Idaho Falls completed'
ON CONFLICT (trip_id, reviewer_id, reviewee_id) DO UPDATE SET
  rating = EXCLUDED.rating,
  comment = EXCLUDED.comment;

-- Notifications
INSERT INTO notifications (user_id, type, title, body, trip_id, request_id, is_read)
SELECT
  u.id,
  'ride_request',
  'New ride request',
  'Josh requested a seat on your Lehi to Idaho Falls trip.',
  t.id,
  rr.id,
  FALSE
FROM users u
JOIN trips t ON t.notes = '[seed-demo] Lehi to Idaho Falls'
JOIN ride_requests rr ON rr.trip_id = t.id
JOIN users rider ON rider.id = rr.rider_id
WHERE u.email = 'seed+tessa@flock.local'
  AND rider.email = 'seed+josh@flock.local'
  AND NOT EXISTS (
    SELECT 1 FROM notifications n
    WHERE n.user_id = u.id
      AND n.trip_id = t.id
      AND n.request_id = rr.id
      AND n.type = 'ride_request'
  );

INSERT INTO notifications (user_id, type, title, body, trip_id, request_id, is_read)
SELECT
  u.id,
  'request_accepted',
  'Ride request accepted',
  'Brad accepted your request for the road trip south.',
  t.id,
  rr.id,
  FALSE
FROM users u
JOIN trips t ON t.notes = '[seed-demo] Spanish Fork to Scottsdale road trip'
JOIN ride_requests rr ON rr.trip_id = t.id
WHERE u.email = 'seed+emma@flock.local'
  AND rr.status = 'accepted'
  AND NOT EXISTS (
    SELECT 1 FROM notifications n
    WHERE n.user_id = u.id
      AND n.trip_id = t.id
      AND n.request_id = rr.id
      AND n.type = 'request_accepted'
  );

INSERT INTO notifications (user_id, type, title, body, trip_id, request_id, is_read)
SELECT
  u.id,
  'ride_request',
  'New ride request',
  'Two riders are asking about your long-haul Provo to DC route.',
  t.id,
  rr.id,
  FALSE
FROM users u
JOIN trips t ON t.notes = '[seed-demo] Provo to Amarillo long haul'
JOIN ride_requests rr ON rr.trip_id = t.id
JOIN users rider ON rider.id = rr.rider_id
WHERE u.email = 'seed+caleb@flock.local'
  AND rider.email = 'seed+sophie@flock.local'
  AND NOT EXISTS (
    SELECT 1 FROM notifications n
    WHERE n.user_id = u.id
      AND n.trip_id = t.id
      AND n.request_id = rr.id
      AND n.type = 'ride_request'
  );

INSERT INTO notifications (user_id, type, title, body, trip_id, request_id, is_read)
SELECT
  u.id,
  'request_accepted',
  'Ride request accepted',
  'Your partial route request on the Colorado trip was accepted.',
  t.id,
  rr.id,
  FALSE
FROM users u
JOIN trips t ON t.notes = '[seed-demo] Farmington to Moab'
JOIN ride_requests rr ON rr.trip_id = t.id
WHERE u.email = 'seed+olivia@flock.local'
  AND rr.status = 'accepted'
  AND NOT EXISTS (
    SELECT 1 FROM notifications n
    WHERE n.user_id = u.id
      AND n.trip_id = t.id
      AND n.request_id = rr.id
      AND n.type = 'request_accepted'
  );
