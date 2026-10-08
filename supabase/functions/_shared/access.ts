import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

import type { Member } from "./auth.ts";
import { HttpError } from "./http.ts";

/**
 * Loads a proposal and its lead, checking the caller may see them (same
 * company; owners see all leads, sales reps only their own).
 */
export async function loadProposalForMember(
  admin: SupabaseClient,
  member: Member,
  proposalId: unknown,
): Promise<
  { proposal: Record<string, unknown>; lead: Record<string, unknown> }
> {
  if (typeof proposalId !== "string" || !/^[0-9a-f-]{36}$/i.test(proposalId)) {
    throw new HttpError(400, "bad_request", "proposal_id is required");
  }
  const { data: proposal } = await admin
    .from("proposals")
    .select("*")
    .eq("id", proposalId)
    .is("deleted_at", null)
    .maybeSingle();
  if (!proposal) {
    throw new HttpError(
      404,
      "not_synced",
      "Proposal has not reached the server yet. Try again when online.",
    );
  }
  const { data: lead } = await admin
    .from("leads")
    .select("*")
    .eq("id", proposal.lead_id)
    .maybeSingle();
  const allowed = lead &&
    proposal.company_id === member.companyId &&
    lead.company_id === member.companyId &&
    (member.role === "owner" || lead.assigned_to === member.userId);
  if (!allowed) throw new HttpError(403, "forbidden", "Not your proposal");
  return { proposal, lead };
}
