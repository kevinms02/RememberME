const User = require('../models/user');
const ErrorResponse = require('../utils/errorResponse');
const asyncHandler = require('../middleware/async');

// @desc      Get user profile
// @route     GET /api/v1/profile
// @access    Private
exports.getProfile = asyncHandler(async (req, res, next) => {
  const user = await User.findById(req.user.id);

  res.status(200).json({
    success: true,
    data: user,
  });
});

// @desc      Update user profile
// @route     PUT /api/v1/profile
// @access    Private
exports.updateProfile = asyncHandler(async (req, res, next) => {
  const { name, email, username } = req.body;

  const user = await User.findByIdAndUpdate(
    req.user.id,
    {
      name,
      email,
      username,
    },
    {
      new: true,
      runValidators: true,
    }
  );

  res.status(200).json({
    success: true,
    data: user,
  });
});

// @desc      Upload profile picture
// @route     PUT /api/v1/profile/photo
// @access    Private
exports.uploadProfilePicture = asyncHandler(async (req, res, next) => {
  // Implementation for photo upload will be added later
  res.status(200).json({
    success: true,
    data: {},
  });
});
