# Flock Carpool MVP

Minimal college-focused carpool matching prototype built for local development with Flutter (web, iOS, Android) and Node.js/Express/PostgreSQL.

## Local Development Quickstart

This project is intended to run entirely on a developer machine.

### Prerequisites

Install these before starting:

- Git
- Docker Desktop (or Docker Engine with Compose)
- Flutter SDK
- Chrome
- Xcode and iOS Simulator (for iOS)
- Android Studio and an Android emulator (for Android)

### 1. Get The Code

```bash
git clone <your-repo-url>
cd Flock
```

If your teammate already has the repo, they only need:

```bash
cd Flock
```

### 2. Start The Backend (Recommended)

The easiest backend setup is Docker Compose. It starts both PostgreSQL and the Node API, waits for the database, runs the SQL migration automatically, and exposes the API on port `3000`.

```bash
docker compose up --build
```

What this starts:

- Backend API: `http://localhost:3000`
- PostgreSQL: `localhost:55432`

Leave that terminal running while using the app.

To stop everything:

```bash
docker compose down
```

To stop everything and wipe the database:

```bash
docker compose down -v
```

### 3. Start Flutter

In a separate terminal:

```bash
flutter pub get
```

Then run one of these:

Chrome:

```bash
flutter run -d chrome
```

iOS simulator:

```bash
open -a Simulator
flutter run -d ios
```

Android emulator:

```bash
flutter emulators
flutter emulators --launch <EMULATOR_ID>
flutter run -d android
```

### 4. First Use

Once both backend and Flutter are running:

1. Register a user.
2. Upload a profile photo during registration.
3. If you want to post trips, complete the required driver profile with your car details.
4. Create a trip as a driver.
5. Register a second user if you want to test ride requests and messaging.
6. Accept the rider request from the driver account.
7. Open messages after acceptance.

## What It Does

- Students register with email and password.
- Drivers post trips between a fixed list of college towns in the Mormon Belt.
- Riders request seats with a short note.
- Drivers accept or reject requests.
- Messages unlock only after a request is accepted.
- Cost-sharing happens offline. There are no payments, pricing fields, or live location features.

## Supported Cities

Cities are hard-coded as string enums in both backend and frontend:

- `provo_ut` -> Provo, UT (BYU)
- `logan_ut` -> Logan, UT (USU)
- `salt_lake_city_ut` -> Salt Lake City, UT (University of Utah)
- `rexburg_id` -> Rexburg, ID (BYU-Idaho)
- `tempe_az` -> Tempe, AZ (ASU)

## Backend Setup

### Recommended: Docker Compose

For most teammates, use:

```bash
docker compose up --build
```

The containerized backend auto-runs the migration on startup. No local Postgres password is needed.

### Manual Local Option (No Docker)

Only use this if you explicitly want to run Node and PostgreSQL outside Docker.

1. Install PostgreSQL locally.
2. Create a database:

```bash
createdb flock_carpool
```

3. Copy the example env file:

```bash
cp .env.example .env
```

4. Update `.env` with your local database credentials.
5. Install backend packages:

```bash
npm install
```

6. Run the schema migration:

```bash
psql "$DATABASE_URL" -f migrations/001_init.sql
psql "$DATABASE_URL" -f migrations/002_driver_profiles.sql
```

7. Start the API:

```bash
npm run dev
```

The backend defaults to `http://localhost:3000`.

### API Endpoints

- `POST /auth/register`
- `POST /auth/login`
- `POST /uploads/profile-photo`
- `POST /users/me/driver-profile`
- `POST /trips`
- `GET /trips`
- `GET /trips/:id`
- `POST /trips/:id/request`
- `POST /requests/:id/accept`
- `POST /requests/:id/reject`
- `GET /trips/:id/messages`
- `POST /trips/:id/messages`

## Flutter Setup

1. Install the Flutter SDK locally and confirm it works:

```bash
flutter doctor
```

2. Fetch Dart packages:

```bash
flutter pub get
```

### Run in Chrome

```bash
flutter run -d chrome
```

The web app targets `http://localhost:3000` by default.

### Run in iOS Simulator

```bash
open -a Simulator
flutter run -d ios
```

The iOS build also targets `http://localhost:3000` by default.

### Run in Android Emulator

```bash
flutter emulators --launch <your_emulator_id>
flutter run -d android
```

The Android build targets `http://10.0.2.2:3000` so the emulator can reach the host machine backend.

## Teammate Notes

- The Flutter app assumes the backend is on `http://localhost:3000` for web and iOS.
- The Android emulator uses `http://10.0.2.2:3000` automatically.
- If the backend is not running, login, registration, trips, and messages will fail.
- Docker Compose is the intended shared local development workflow.
- If port `3000` or `55432` is already taken on a machine, stop the conflicting service or update `docker-compose.yml`.

## pgAdmin Connection (When Using Docker Compose)

If a teammate wants to inspect the Dockerized database in pgAdmin:

- Host: `localhost`
- Port: `55432`
- Username: `postgres`
- Password: leave blank
- Maintenance DB: `postgres`
- App DB: `flock_carpool`

## Project Layout

- `server.js`
- `routes/`
- `controllers/`
- `models/`
- `migrations/`
- `.env.example`
- `lib/screens/`
- `lib/models/`
- `lib/services/api.dart`
- `lib/main.dart`

## Assumptions And Limitations

- This is a hackathon prototype for local development only.
- JWTs are kept in memory only; refreshing the app requires logging in again.
- Driver messaging is per trip and can target accepted riders.
- There is no seat decrement logic after acceptance.
- There is no production-grade validation, moderation, or abuse prevention.
- `profile_photo_url` is stored as text only; the UI just keeps the URL value.
- The backend Docker workflow is intended for team setup simplicity, not production deployment.
