import { createClient } from "jsr:@supabase/supabase-js@2";

// SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY los inyecta Supabase automáticamente
// en el runtime de cada Edge Function; no hace falta "supabase secrets set" para ellas.
export function getSupabaseAdmin() {
  const url = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  return createClient(url, serviceRoleKey, {
    auth: { persistSession: false },
  });
}

export function getCallingUserClient(authHeader: string | null) {
  const url = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  return createClient(url, anonKey, {
    global: { headers: { Authorization: authHeader ?? "" } },
    auth: { persistSession: false },
  });
}

export const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
