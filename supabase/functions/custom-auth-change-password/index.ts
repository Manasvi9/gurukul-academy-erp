import bcrypt from "npm:bcryptjs@2.4.3";
import {
  jsonResponse,
  preflight,
  requireString,
  serviceClient,
  verifyJwt,
} from "../_shared/custom_auth.ts";

Deno.serve(async (request) => {
  const preflightResponse = preflight(request);
  if (preflightResponse) return preflightResponse;

  try {
    const authorization = request.headers.get("Authorization") ?? "";
    const token = authorization.replace("Bearer ", "");
    const payload = await verifyJwt(token);
    const identityId = requireString(payload.sub, "sub");

    const body = await request.json();
    const currentPassword = requireString(body.current_password, "current_password");
    const newPassword = requireString(body.new_password, "new_password");

    if (newPassword.length < 8) {
      return jsonResponse({ error: "Password must be at least 8 characters." }, 400);
    }

    const supabase = serviceClient();
    const { data: identity, error } = await supabase
      .from("custom_auth_identities")
      .select("*")
      .eq("id", identityId)
      .maybeSingle();

    if (error) throw error;
    if (!identity || !identity.is_active) {
      return jsonResponse({ error: "Invalid session." }, 401);
    }

    const validPassword = await bcrypt.compare(
      currentPassword,
      identity.password_hash,
    );
    if (!validPassword) {
      return jsonResponse({ error: "Current password is incorrect." }, 401);
    }

    const passwordHash = await bcrypt.hash(newPassword, 12);
    const { error: updateError } = await supabase
      .from("custom_auth_identities")
      .update({
        password_hash: passwordHash,
        must_change_password: false,
      })
      .eq("id", identity.id);

    if (updateError) throw updateError;
    return jsonResponse({ ok: true });
  } catch (error) {
    return jsonResponse({ error: error.message ?? "Password update failed." }, 500);
  }
});
