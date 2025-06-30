const Memory = require('../models/memory');
const ErrorResponse = require('../utils/errorResponse');
const asyncHandler = require('../middleware/async');
const { v4: uuidv4 } = require('uuid');

// @desc      Get all memories for a user
// @route     GET /api/v1/memories
// @access    Private
exports.getMemories = asyncHandler(async (req, res, next) => {
  const memories = await Memory.find({ user: req.user.id });

  res.status(200).json({
    success: true,
    count: memories.length,
    data: memories,
  });
});

// @desc      Get single memory
// @route     GET /api/v1/memories/:id
// @access    Public
exports.getMemory = asyncHandler(async (req, res, next) => {
  const memory = await Memory.findById(req.params.id);

  if (!memory) {
    return next(
      new ErrorResponse(`Memory not found with id of ${req.params.id}`, 404)
    );
  }

  res.status(200).json({
    success: true,
    data: memory,
  });
});

// @desc      Create new memory
// @route     POST /api/v1/memories
// @access    Private
exports.createMemory = asyncHandler(async (req, res, next) => {
  req.body.user = req.user.id;

  // Generate a unique URL
  const url = `${req.protocol}://${req.get('host')}/memories/${uuidv4()}`;
  req.body.url = url;

  // Handle media uploads
  let mediaUrls = [];
  if (req.files && req.files.length > 0) {
    mediaUrls = req.files.map(
      (file) => `${req.protocol}://${req.get('host')}/uploads/memories/${file.filename}`
    );
  }
  req.body.media = mediaUrls;

  const memory = await Memory.create(req.body);

  res.status(201).json({
    success: true,
    data: memory,
  });
});

// @desc      Update memory
// @route     PUT /api/v1/memories/:id
// @access    Private
exports.updateMemory = asyncHandler(async (req, res, next) => {
  let memory = await Memory.findById(req.params.id);

  if (!memory) {
    return next(
      new ErrorResponse(`Memory not found with id of ${req.params.id}`, 404)
    );
  }

  // Make sure user is memory owner
  if (memory.user.toString() !== req.user.id) {
    return next(
      new ErrorResponse(
        `User ${req.user.id} is not authorized to update this memory`,
        401
      )
    );
  }

  memory = await Memory.findByIdAndUpdate(req.params.id, req.body, {
    new: true,
    runValidators: true,
  });

  res.status(200).json({
    success: true,
    data: memory,
  });
});

// @desc      Delete memory
// @route     DELETE /api/v1/memories/:id
// @access    Private
exports.deleteMemory = asyncHandler(async (req, res, next) => {
  const memory = await Memory.findById(req.params.id);

  if (!memory) {
    return next(
      new ErrorResponse(`Memory not found with id of ${req.params.id}`, 404)
    );
  }

  // Make sure user is memory owner
  if (memory.user.toString() !== req.user.id) {
    return next(
      new ErrorResponse(
        `User ${req.user.id} is not authorized to delete this memory`,
        401
      )
    );
  }

  await memory.remove();

  res.status(200).json({
    success: true,
    data: {},
  });
});

// @desc      Upload media for memory
// @route     PUT /api/v1/memories/:id/media
// @access    Private
exports.uploadMemoryMedia = asyncHandler(async (req, res, next) => {
  const memory = await Memory.findById(req.params.id);
  if (!memory) {
    return next(new ErrorResponse(`Memory not found with id of ${req.params.id}`, 404));
  }
  // Make sure user is memory owner
  if (memory.user.toString() !== req.user.id) {
    return next(new ErrorResponse(`User ${req.user.id} is not authorized to update this memory`, 401));
  }
  let mediaUrls = [];
  if (req.files && req.files.length > 0) {
    mediaUrls = req.files.map(
      (file) => `${req.protocol}://${req.get('host')}/uploads/memories/${file.filename}`
    );
  }
  memory.media = mediaUrls;
  await memory.save();
  res.status(200).json({
    success: true,
    data: memory,
  });
});
