const path = require('path');

function uploadProfilePhotoHandler(req, res) {
  if (!req.file) {
    return res.status(400).json({ error: 'A profile photo file is required.' });
  }

  const baseUrl = `${req.protocol}://${req.get('host')}`;
  const photoUrl = `${baseUrl}/uploads/${path.basename(req.file.path)}`;

  return res.status(201).json({
    photoUrl,
  });
}

module.exports = {
  uploadProfilePhotoHandler,
};
