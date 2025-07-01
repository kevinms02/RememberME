const { createClient } = require('@supabase/supabase-js');
const ErrorResponse = require('../utils/errorResponse');

// Inisialisasi Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL || 'https://dgtwlveibsmobifgcsan.supabase.co',
  process.env.SUPABASE_KEY ||
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRndHdsdmVpYnNtb2JpZmdjc2FuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0MDg1NzIsImV4cCI6MjA2NTk4NDU3Mn0.1u5oceSFwdJT5ZR1KyjGi61YQOBRsm668GZFdBcr_7M'
);

// Protect routes
exports.protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return next(new ErrorResponse('Not authorized to access this route', 401));
  }

  try {
    // Verifikasi token dengan Supabase
    const { data, error } = await supabase.auth.getUser(token);
    if (error || !data.user) {
      return next(new ErrorResponse('Not authorized to access this route', 401));
    }
    req.user = data.user;
    req.headers['x-user-id'] = data.user.id; // Untuk kompatibilitas endpoint
    next();
  } catch (err) {
    return next(new ErrorResponse('Not authorized to access this route', 401));
  }
};
