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
    const role = requireString(payload.role, "role");
    const supabase = serviceClient();

    if (role === "parent") {
      const { data, error } = await supabase
        .from("student_guardians")
        .select("student_id")
        .eq("parent_identity_id", identityId);
      if (error) throw error;
      const childCount = data?.length ?? 0;
      return jsonResponse({
        role,
        title: "Parent Dashboard",
        cards: [
          metric("children", "Children", String(childCount), "groups", "/students"),
          metric("attendance", "Attendance", "View", "fact_check", "/students"),
          metric("fees", "Fees", "View", "payments", "/students"),
          metric("homework", "Homework", "View", "assignment", null),
          metric("marks", "Marks", "View", "grading", null),
        ],
        notifications: [],
      });
    }

    if (role === "student") {
      return jsonResponse({
        role,
        title: "Student Dashboard",
        cards: [
          metric("attendance", "Attendance", "View", "fact_check", "/students"),
          metric("homework", "Homework", "View", "assignment", null),
          metric("marks", "Marks", "View", "grading", null),
          metric("profile", "Profile", "View", "person", "/students"),
        ],
        notifications: [],
      });
    }

    return jsonResponse({ error: "Unsupported dashboard role." }, 403);
  } catch (error) {
    return jsonResponse(
      { error: error.message ?? "Dashboard request failed." },
      500,
    );
  }
});

function metric(
  key: string,
  title: string,
  value: string,
  iconName: string,
  routePath: string | null,
) {
  return {
    key,
    title,
    value,
    icon_name: iconName,
    route_path: routePath,
  };
}
