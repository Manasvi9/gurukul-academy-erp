import {
  createSession,
  jsonResponse,
  preflight,
  requireString,
  serviceClient,
  sha256,
} from "../_shared/custom_auth.ts";

Deno.serve(async (request) => {
  const preflightResponse = preflight(request);
  if (preflightResponse) return preflightResponse;

  try {
    const body = await request.json();
    const refreshToken = requireString(body.refresh_token, "refresh_token");
    const refreshTokenHash = await sha256(refreshToken);
    const supabase = serviceClient();

    const { data: session, error } = await supabase
      .from("custom_auth_sessions")
      .select("id, expires_at, revoked_at, custom_auth_identities(*)")
      .eq("refresh_token_hash", refreshTokenHash)
      .maybeSingle();

    if (error) throw error;
    if (!session || session.revoked_at || new Date(session.expires_at) <= new Date()) {
      return jsonResponse({ error: "Invalid session." }, 401);
    }

    await supabase
      .from("custom_auth_sessions")
      .update({ revoked_at: new Date().toISOString() })
      .eq("id", session.id);

    return jsonResponse(await createSession(session.custom_auth_identities));
  } catch (error) {
    return jsonResponse({ error: error.message ?? "Session refresh failed." }, 500);
  }
});
