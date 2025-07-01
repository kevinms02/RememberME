// Semua endpoint memories sudah dihandle di server.js menggunakan Supabase.
// File ini tidak lagi digunakan.
  getMemories,
  getMemory,
  createMemory,
  updateMemory,
  deleteMemory,
  uploadMemoryMedia,
} = require('../controllers/memories');
const multer = require('../config/multer');

const router = express.Router();

const { protect } = require('../middleware/auth');

router
  .route('/')
  .get(protect, getMemories)
  .post(protect, multer.array('media', 3), createMemory);

router
  .route('/:id')
  .get(getMemory)
  .put(protect, updateMemory)
  .delete(protect, deleteMemory);

router.route('/:id/media').put(protect, multer.array('media', 3), uploadMemoryMedia);

module.exports = router;
