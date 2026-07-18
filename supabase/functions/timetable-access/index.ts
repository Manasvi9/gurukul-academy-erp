import { jsonResponse, preflight, requireString, serviceClient, verifyJwt } from "../_shared/custom_auth.ts";

Deno.serve(async (request) => {
  const preflightResponse = preflight(request);
  if (preflightResponse) return preflightResponse;
  try {
    const token = (request.headers.get("Authorization") ?? "").replace("Bearer ", "");
    const payload = await verifyJwt(token);
    const identityId = requireString(payload.sub, "sub");
    const role = requireString(payload.role, "role");
    const client = serviceClient();
    const table = role === "parent" ? "student_guardians" : "student_user_links";
    const column = role === "parent" ? "parent_identity_id" : "student_identity_id";
    if (role !== "parent" && role !== "student") return jsonResponse({ error: "Unsupported role." }, 403);
    const { data: links, error: linksError } = await client.from(table).select("student_id").eq(column, identityId);
    if (linksError) throw linksError;
    const studentIds = (links ?? []).map((item) => item.student_id);
    if (studentIds.length === 0) return jsonResponse([]);
    const { data: profiles, error: profilesError } = await client.from("student_profile_details").select("class_id, section_id").in("id", studentIds);
    if (profilesError) throw profilesError;
    const requests = (profiles ?? []).map((profile) => client.from("timetable_entry_details").select().eq("class_id", profile.class_id).eq("section_id", profile.section_id));
    const responses = await Promise.all(requests);
    const entries = responses.flatMap((response) => { if (response.error) throw response.error; return response.data ?? []; });
    return jsonResponse([...new Map(entries.map((entry) => [entry.id, entry])).values()]);
  } catch (error) {
    return jsonResponse({ error: error.message ?? "Timetable request failed." }, 500);
  }
});
