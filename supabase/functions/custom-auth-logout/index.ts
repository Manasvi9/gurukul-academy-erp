import {
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

    const { error } = await serviceClient()
      .from("custom_auth_sessions")
      .update({ revoked_at: new Date().toISOString() })
      .eq("refresh_token_hash", refreshTokenHash);

    if (error) throw error;
    return jsonResponse({ ok: true });
  } catch (error) {
    return jsonResponse({ error: error.message ?? "Logout failed." }, 500);
  }
});
