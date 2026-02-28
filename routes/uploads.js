const express = require('express');
const fs = require('fs');
const multer = require('multer');
const path = require('path');

const { uploadProfilePhotoHandler } = require('../controllers/uploadController');

const uploadsDir = path.join(__dirname, '..', 'uploads');
fs.mkdirSync(uploadsDir, { recursive: true });

function hasAllowedImageExtension(fileName) {
  const lowerName = fileName.toLowerCase();
  return [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.heic',
    '.heif',
  ].some((extension) => lowerName.endsWith(extension));
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (_req, file, cb) => {
    const safeBaseName = path
      .parse(file.originalname)
      .name
      .replace(/[^a-zA-Z0-9_-]/g, '_')
      .slice(0, 40);
    const extension = path.extname(file.originalname) || '.jpg';
    cb(null, `${Date.now()}-${safeBaseName}${extension}`);
  },
});

const upload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
  fileFilter: (_req, file, cb) => {
    const mimeLooksValid = file.mimetype.startsWith('image/');
    const extensionLooksValid = hasAllowedImageExtension(file.originalname);

    if (!mimeLooksValid && !extensionLooksValid) {
      cb(new Error('Only image uploads are allowed.'));
      return;
    }
    cb(null, true);
  },
});

const router = express.Router();

router.post('/profile-photo', upload.single('photo'), uploadProfilePhotoHandler);

module.exports = router;
