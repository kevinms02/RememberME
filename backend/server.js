const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

// Load env vars
dotenv.config({ path: './config/config.env' });

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);

const app = express();
app.use(express.json());
app.use(cors());

// Health check endpoint
app.get('/', (req, res) => {
  res.send('RememberME backend is running!');
});

// Supabase Auth: Login
app.post('/api/v1/auth/login', async (req, res) => {
  const { email, password } = req.body;
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) return res.status(401).json({ error: error.message });
  res.json({ user: data.user, session: data.session });
});

// Supabase Auth: Register
app.post('/api/v1/auth/register', async (req, res) => {
  const { email, password, username, name } = req.body;
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: { username, name }
    }
  });
  if (error) return res.status(400).json({ error: error.message });
  res.json({ user: data.user });
});

// --- MEMORIES ENDPOINTS (Supabase) ---
// Get all memories for a user
app.get('/api/v1/memories', async (req, res) => {
  const userId = req.headers['x-user-id']; // Ganti dengan cara otentikasi yang sesuai
  if (!userId) return res.status(401).json({ error: 'Unauthorized' });
  const { data, error } = await supabase
    .from('memories')
    .select('*')
    .eq('user_id', userId);
  if (error) return res.status(500).json({ error: error.message });
  res.json({ success: true, count: data.length, data });
});

// Get single memory
app.get('/api/v1/memories/:id', async (req, res) => {
  const { id } = req.params;
  const { data, error } = await supabase
    .from('memories')
    .select('*')
    .eq('id', id)
    .single();
  if (error || !data) return res.status(404).json({ error: 'Memory not found' });
  res.json({ success: true, data });
});

// Create new memory
app.post('/api/v1/memories', async (req, res) => {
  const userId = req.headers['x-user-id']; // Ganti dengan cara otentikasi yang sesuai
  if (!userId) return res.status(401).json({ error: 'Unauthorized' });
  const memory = { ...req.body, user_id: userId };
  const { data, error } = await supabase
    .from('memories')
    .insert([memory])
    .select()
    .single();
  if (error) return res.status(400).json({ error: error.message });
  res.status(201).json({ success: true, data });
});

// Update memory
app.put('/api/v1/memories/:id', async (req, res) => {
  const userId = req.headers['x-user-id'];
  const { id } = req.params;
  if (!userId) return res.status(401).json({ error: 'Unauthorized' });
  // Pastikan memory milik user
  const { data: memory, error: findError } = await supabase
    .from('memories')
    .select('*')
    .eq('id', id)
    .single();
  if (findError || !memory) return res.status(404).json({ error: 'Memory not found' });
  if (memory.user_id !== userId) return res.status(403).json({ error: 'Forbidden' });
  const { data, error } = await supabase
    .from('memories')
    .update(req.body)
    .eq('id', id)
    .select()
    .single();
  if (error) return res.status(400).json({ error: error.message });
  res.json({ success: true, data });
});

// Delete memory
app.delete('/api/v1/memories/:id', async (req, res) => {
  const userId = req.headers['x-user-id'];
  const { id } = req.params;
  if (!userId) return res.status(401).json({ error: 'Unauthorized' });
  // Pastikan memory milik user
  const { data: memory, error: findError } = await supabase
    .from('memories')
    .select('*')
    .eq('id', id)
    .single();
  if (findError || !memory) return res.status(404).json({ error: 'Memory not found' });
  if (memory.user_id !== userId) return res.status(403).json({ error: 'Forbidden' });
  const { error } = await supabase
    .from('memories')
    .delete()
    .eq('id', id);
  if (error) return res.status(400).json({ error: error.message });
  res.json({ success: true, data: {} });
});

// --- PROFILE ENDPOINTS (Supabase) ---
// Get user profile
app.get('/api/v1/profile', async (req, res) => {
  const userId = req.headers['x-user-id'];
  if (!userId) return res.status(401).json({ error: 'Unauthorized' });
  const { data, error } = await supabase.auth.admin.getUserById(userId);
  if (error || !data) return res.status(404).json({ error: 'User not found' });
  res.json({ success: true, data: data.user });
});

// Update user profile (metadata)
app.put('/api/v1/profile', async (req, res) => {
  const userId = req.headers['x-user-id'];
  if (!userId) return res.status(401).json({ error: 'Unauthorized' });
  const { name, username } = req.body;
  const { data, error } = await supabase.auth.admin.updateUserById(userId, {
    user_metadata: { name, username }
  });
  if (error) return res.status(400).json({ error: error.message });
  res.json({ success: true, data: data.user });
});

module.exports = app;
