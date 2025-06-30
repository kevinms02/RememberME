const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
// const connectDB = require('./config/database'); // Uncomment if using MongoDB

// Load env vars
dotenv.config({ path: './backend/config/config.env' });

// Uncomment if using MongoDB
// connectDB();

const app = express();

// Body parser
app.use(express.json());

// Enable CORS
app.use(cors());

// Serve uploads directory statically for media access
app.use('/uploads', express.static('uploads'));

// Mount routers
const auth = require('./backend/routes/auth');
const memories = require('./backend/routes/memories');
const profile = require('./backend/routes/profile');

app.use('/api/v1/auth', auth);
app.use('/api/v1/memories', memories);
app.use('/api/v1/profile', profile);

// Health check endpoint
app.get('/', (req, res) => {
  res.send('RememberME backend is running!');
});

const PORT = process.env.PORT || 5000;

const server = app.listen(
  PORT,
  () => console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`)
);

// Handle unhandled promise rejections
process.on('unhandledRejection', (err, promise) => {
  console.log(`Error: ${err.message}`);
  // Close server & exit process
  server.close(() => process.exit(1));
});
