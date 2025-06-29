const mongoose = require('mongoose');

const MemorySchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a title'],
    trim: true,
  },
  media: [
    {
      type: String,
      required: true,
    },
  ],
  date: {
    type: Date,
    required: true,
  },
  notes: {
    type: String,
    required: true,
  },
  url: {
    type: String,
    required: true,
    unique: true,
  },
  user: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Memory', MemorySchema);
