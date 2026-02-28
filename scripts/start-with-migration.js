require('dotenv').config();

const fs = require('fs/promises');
const path = require('path');

const db = require('../db');

const MIGRATIONS_DIR = path.join(__dirname, '..', 'migrations');
const MAX_ATTEMPTS = 30;
const RETRY_DELAY_MS = 2000;

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

async function waitForDatabase() {
  for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt += 1) {
    try {
      await db.query('SELECT 1');
      console.log('Database connection established.');
      return;
    } catch (error) {
      console.log(`Waiting for database (${attempt}/${MAX_ATTEMPTS})...`);
      if (attempt === MAX_ATTEMPTS) {
        throw error;
      }
      await sleep(RETRY_DELAY_MS);
    }
  }
}

async function runMigrations() {
  const migrationFiles = (await fs.readdir(MIGRATIONS_DIR))
    .filter((fileName) => fileName.endsWith('.sql'))
    .sort();

  for (const fileName of migrationFiles) {
    const sql = await fs.readFile(path.join(MIGRATIONS_DIR, fileName), 'utf8');
    await db.query(sql);
    console.log(`Applied migration: ${fileName}`);
  }
}

async function start() {
  try {
    await waitForDatabase();
    await runMigrations();
    require('../server');
  } catch (error) {
    console.error('Backend startup failed.', error);
    process.exit(1);
  }
}

start();
