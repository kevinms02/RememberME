const express = require('express');
const {
  getProfile,
  updateProfile,
  uploadProfilePicture,
} = require('../controllers/profile');

const router = express.Router();

const { protect } = require('../middleware/auth');

router
  .route('/')
  .get(protect, getProfile)
  .put(protect, updateProfile);

router.route('/photo').put(protect, uploadProfilePicture);

module.exports = router;
