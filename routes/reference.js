const express = require('express');
const router = express.Router();

router.get('/', async (req, res) => {
  res.json({ message: 'Reference route working' });
});

module.exports = router;