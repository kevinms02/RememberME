import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

export default function ConfirmEmail() {
  const router = useRouter();
  const { query } = router;
  const [status, setStatus] = useState('Verifying...');

  useEffect(() => {
    async function verify() {
      if (query.access_token) {
        const { error } = await supabase.auth.verifyOtp({
          token: query.access_token,
          type: 'email',
        });
        if (error) {
          setStatus('Verifikasi gagal: ' + error.message);
        } else {
          setStatus('Email berhasil diverifikasi! Silakan login.');
        }
      } else {
        setStatus('Token verifikasi tidak ditemukan.');
      }
    }
    verify();
  }, [query.access_token]);

  return (
    <div style={{textAlign: 'center', marginTop: '100px'}}>
      <h2>Verifikasi Email</h2>
      <p>{status}</p>
    </div>
  );
}
