require('dotenv').config();

const fs = require('fs/promises');
const path = require('path');

const db = require('../db');

const MIGRATION_PATH = path.join(__dirname, '..', 'migrations', '001_init.sql');
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

async function runMigration() {
  const sql = await fs.readFile(MIGRATION_PATH, 'utf8');
  await db.query(sql);
  console.log('Migration applied.');
}

async function start() {
  try {
    await waitForDatabase();
    await runMigration();
    require('../server');
  } catch (error) {
    console.error('Backend startup failed.', error);
    process.exit(1);
  }
}

start();
