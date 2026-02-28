require('dotenv').config();

const fs = require('fs');
const path = require('path');

const cors = require('cors');
const express = require('express');

const authRoutes = require('./routes/auth');
const tripRoutes = require('./routes/trips');
const requestRoutes = require('./routes/requests');
const uploadRoutes = require('./routes/uploads');
const userRoutes = require('./routes/users');

const app = express();
const port = process.env.PORT || 3000;
const uploadsDir = path.join(__dirname, 'uploads');

fs.mkdirSync(uploadsDir, { recursive: true });

app.use(
  cors({
    origin: true,
    credentials: false,
  }),
);
app.use(express.json());
app.use('/uploads', express.static(uploadsDir));

app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    message: 'Flock backend is running.',
  });
});

app.use('/auth', authRoutes);
app.use('/trips', tripRoutes);
app.use('/requests', requestRoutes);
app.use('/uploads', uploadRoutes);
app.use('/users', userRoutes);

app.use((err, _req, res, _next) => {
  console.error('Server error:', err);
  const status = err.status ?? err.statusCode ?? 500;
  const message = err.message || 'Unexpected server error.';
  res.status(status >= 400 ? status : 500).json({ error: message });
});

app.use((_req, res) => {
  res.status(404).json({ error: 'Not found.' });
});

app.listen(port, () => {
  console.log(`Flock backend listening on http://localhost:${port}`);
});
