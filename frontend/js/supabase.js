// ==========================================
// NovaMente
// Supabase Client
// ==========================================

const SUPABASE_URL =
"https://vouoxlnggfbfivrfuwjz.supabase.co";

const SUPABASE_ANON_KEY =
"sb_publishable_yhkPdbQ5yISsoXLxctYTwQ_-Tu3_mWt";

window.novaSupabase = window.supabase.createClient(
    SUPABASE_URL,
    SUPABASE_ANON_KEY
);
