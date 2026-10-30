// supabase.js – configuración generada automáticamente
// URL y clave pública de tu proyecto Supabase (versión base del endpoint)
const SUPABASE_URL = "https://laomvxilygbkkabaracz.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_C5c0SDrTDhB3ulcdhohlgg_XbX9xpFA";

// Initialise the Supabase client (the global `supabase` variable comes from the CDN script)
window.supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Helper para cerrar sesión
window.logout = async () => {
  const { error } = await supabase.auth.signOut();
  if (error) console.error('Logout error', error);
  else location.href = 'index.html';
};
