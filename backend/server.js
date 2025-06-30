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

// TODO: Tambahkan endpoint memories dan profile menggunakan Supabase

module.exports = app;
