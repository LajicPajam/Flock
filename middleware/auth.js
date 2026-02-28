const jwt = require('jsonwebtoken');

function readBearerToken(header) {
  if (!header || !header.startsWith('Bearer ')) {
    return null;
  }

  return header.slice(7).trim();
}

function verifyToken(token) {
  return jwt.verify(token, process.env.JWT_SECRET);
}

function authRequired(req, res, next) {
  const token = readBearerToken(req.headers.authorization);

  if (!token) {
    return res.status(401).json({ error: 'Authentication required.' });
  }

  try {
    req.user = verifyToken(token);
    return next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token.' });
  }
}

function getOptionalUser(req) {
  const token = readBearerToken(req.headers.authorization);

  if (!token) {
    return null;
  }

  try {
    return verifyToken(token);
  } catch (error) {
    return null;
  }
}

module.exports = {
  authRequired,
  getOptionalUser,
};
