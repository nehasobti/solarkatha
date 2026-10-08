import {
  createClient,
  type SupabaseClient,
} from "npm:@supabase/supabase-js@2";

import { HttpError, requireEnv } from "./http.ts";

export interface Member {
  userId: string;
  companyId: string;
  role: "owner" | "sales" | "installer";
  /** Service-role client: bypasses RLS, use only after checks. */
  admin: SupabaseClient;
}

/**
 * Verifies the caller's JWT and loads their active profile. Every function
 * calls this before doing anything else.
 */
export async function requireMember(req: Request): Promise<Member> {
  const auth = req.headers.get("Authorization") ?? "";
  const token = auth.replace(/^Bearer\s+/i, "");
  if (!token) throw new HttpError(401, "unauthorized", "Missing token");

  const admin = createClient(
    requireEnv("SUPABASE_URL"),
    requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
    { auth: { persistSession: false } },
  );
  const { data: userData, error } = await admin.auth.getUser(token);
  if (error || !userData.user) {
    throw new HttpError(401, "unauthorized", "Invalid or expired token");
  }

  const { data: profile } = await admin
    .from("profiles")
    .select("company_id, role, active, deleted_at")
    .eq("id", userData.user.id)
    .maybeSingle();
  if (!profile || !profile.active || profile.deleted_at) {
    throw new HttpError(403, "forbidden", "No active team membership");
  }
  return {
    userId: userData.user.id,
    companyId: profile.company_id as string,
    role: profile.role as Member["role"],
    admin,
  };
}

/** Reads an `app_config` value, preferring the company's own row. */
export async function configValue<T>(
  admin: SupabaseClient,
  companyId: string,
  key: string,
  fallback: T,
): Promise<T> {
  const { data } = await admin
    .from("app_config")
    .select("company_id, value")
    .eq("key", key)
    .or(`company_id.is.null,company_id.eq.${companyId}`);
  const rows = (data ?? []) as { company_id: string | null; value: T }[];
  const own = rows.find((r) => r.company_id === companyId);
  return (own ?? rows.find((r) => r.company_id === null))?.value ?? fallback;
}
