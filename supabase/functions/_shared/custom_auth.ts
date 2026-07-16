import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

export type CustomAuthIdentity = {
  id: string;
  role: "parent" | "student";
  identifier: string;
  password_hash: string;
  display_name: string;
  must_change_password: boolean;
  is_active: boolean;
  failed_attempts: number;
  locked_until: string | null;
};

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export function serviceClient() {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    },
  );
}

export function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

export function preflight(request: Request): Response | null {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  return null;
}

export function requireString(value: unknown, name: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`${name} is required.`);
  }
  return value.trim();
}

export function base64Url(bytes: Uint8Array): string {
  return btoa(String.fromCharCode(...bytes))
    .replaceAll("+", "-")
    .replaceAll("/", "_")
    .replaceAll("=", "");
}

export function randomToken(): string {
  const bytes = new Uint8Array(32);
  crypto.getRandomValues(bytes);
  return base64Url(bytes);
}

export async function sha256(value: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return base64Url(new Uint8Array(digest));
}

export async function signJwt(payload: Record<string, unknown>): Promise<string> {
  const header = { alg: "HS256", typ: "JWT" };
  const encodedHeader = base64Url(
    new TextEncoder().encode(JSON.stringify(header)),
  );
  const encodedPayload = base64Url(
    new TextEncoder().encode(JSON.stringify(payload)),
  );
  const data = `${encodedHeader}.${encodedPayload}`;
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(Deno.env.get("CUSTOM_AUTH_JWT_SECRET")!),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(data),
  );
  return `${data}.${base64Url(new Uint8Array(signature))}`;
}

export async function verifyJwt(token: string): Promise<Record<string, unknown>> {
  const parts = token.split(".");
  if (parts.length !== 3) {
    throw new Error("Invalid token.");
  }

  const [encodedHeader, encodedPayload, signature] = parts;
  const expected = await signRaw(`${encodedHeader}.${encodedPayload}`);
  if (signature !== expected) {
    throw new Error("Invalid token signature.");
  }

  const payload = JSON.parse(
    new TextDecoder().decode(base64UrlDecode(encodedPayload)),
  ) as Record<string, unknown>;
  if (typeof payload.exp !== "number" || payload.exp <= Math.floor(Date.now() / 1000)) {
    throw new Error("Token expired.");
  }
  return payload;
}

async function signRaw(data: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(Deno.env.get("CUSTOM_AUTH_JWT_SECRET")!),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(data),
  );
  return base64Url(new Uint8Array(signature));
}

function base64UrlDecode(value: string): Uint8Array {
  const padded = value.replaceAll("-", "+").replaceAll("_", "/").padEnd(
    Math.ceil(value.length / 4) * 4,
    "=",
  );
  return Uint8Array.from(atob(padded), (char) => char.charCodeAt(0));
}

export async function createSession(identity: CustomAuthIdentity) {
  const now = Math.floor(Date.now() / 1000);
  const accessToken = await signJwt({
    sub: identity.id,
    role: identity.role,
    iat: now,
    exp: now + 60 * 30,
  });
  const refreshToken = randomToken();
  const refreshTokenHash = await sha256(refreshToken);
  const refreshExpiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24 * 30);

  const supabase = serviceClient();
  const { error } = await supabase.from("custom_auth_sessions").insert({
    custom_auth_identity_id: identity.id,
    refresh_token_hash: refreshTokenHash,
    expires_at: refreshExpiresAt.toISOString(),
  });
  if (error) {
    throw error;
  }

  return {
    user: {
      id: identity.id,
      role: identity.role,
      display_name: identity.display_name,
      must_change_password: identity.must_change_password,
    },
    access_token: accessToken,
    refresh_token: refreshToken,
    expires_at: new Date((now + 60 * 30) * 1000).toISOString(),
  };
}
