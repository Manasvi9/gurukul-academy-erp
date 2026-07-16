import bcrypt from "npm:bcryptjs@2.4.3";
import {
  createSession,
  jsonResponse,
  preflight,
  requireString,
  serviceClient,
} from "../_shared/custom_auth.ts";

Deno.serve(async (request) => {
  const preflightResponse = preflight(request);
  if (preflightResponse) return preflightResponse;

  try {
    const body = await request.json();
    const role = requireString(body.role, "role");
    const identifier = role === "parent"
      ? requireString(body.mobile_number, "mobile_number")
      : requireString(body.sr_number, "sr_number");
    const password = requireString(body.password, "password");

    if (role !== "parent" && role !== "student") {
      return jsonResponse({ error: "Unsupported custom auth role." }, 400);
    }

    const supabase = serviceClient();
    const { data: identity, error } = await supabase
      .from("custom_auth_identities")
      .select("*")
      .eq("role", role)
      .eq("identifier", identifier)
      .maybeSingle();

    if (error) throw error;
    if (!identity || !identity.is_active) {
      return jsonResponse({ error: "Invalid credentials." }, 401);
    }

    if (identity.locked_until && new Date(identity.locked_until) > new Date()) {
      return jsonResponse({ error: "Account is temporarily locked." }, 423);
    }

    const validPassword = await bcrypt.compare(password, identity.password_hash);
    if (!validPassword) {
      const failedAttempts = Number(identity.failed_attempts ?? 0) + 1;
      await supabase
        .from("custom_auth_identities")
        .update({
          failed_attempts: failedAttempts,
          locked_until: failedAttempts >= 5
            ? new Date(Date.now() + 1000 * 60 * 15).toISOString()
            : null,
        })
        .eq("id", identity.id);
      return jsonResponse({ error: "Invalid credentials." }, 401);
    }

    await supabase
      .from("custom_auth_identities")
      .update({
        failed_attempts: 0,
        locked_until: null,
        last_login_at: new Date().toISOString(),
      })
      .eq("id", identity.id);

    return jsonResponse(await createSession(identity));
  } catch (error) {
    return jsonResponse({ error: error.message ?? "Login failed." }, 500);
  }
});
