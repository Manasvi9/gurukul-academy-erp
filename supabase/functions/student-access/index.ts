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
    const body = await request.json();
    const action = requireString(body.action, "action");
    const supabase = serviceClient();

    const allowedStudentIds = await studentIdsForIdentity(
      supabase,
      identityId,
      role,
    );

    if (allowedStudentIds.length === 0) {
      return jsonResponse(action === "details" ? null : []);
    }

    if (action === "search") {
      const query = String(body.search_query ?? "").trim().toLowerCase();
      let request = supabase
        .from("student_list_details")
        .select("*")
        .in("id", allowedStudentIds)
        .eq("is_archived", false)
        .limit(50);

      if (query.length > 0) {
        request = request.or(
          [
            `student_name.ilike.%${query}%`,
            `sr_number.ilike.%${query}%`,
            `father_name.ilike.%${query}%`,
            `mother_name.ilike.%${query}%`,
            `parent_mobile_number.ilike.%${query}%`,
          ].join(","),
        );
      }

      const { data, error } = await request.order("student_name");
      if (error) throw error;
      return jsonResponse(data ?? []);
    }

    if (action === "recently_viewed") {
      const { data, error } = await supabase
        .from("student_list_details")
        .select("*")
        .in("id", allowedStudentIds)
        .eq("is_archived", false)
        .order("student_name");
      if (error) throw error;
      return jsonResponse(data ?? []);
    }

    if (action === "list_by_section") {
      const academicYearId = requireString(body.academic_year_id, "academic_year_id");
      const classId = requireString(body.class_id, "class_id");
      const sectionId = requireString(body.section_id, "section_id");
      const { data, error } = await supabase
        .from("student_list_details")
        .select("*")
        .in("id", allowedStudentIds)
        .eq("academic_year_id", academicYearId)
        .eq("class_id", classId)
        .eq("section_id", sectionId)
        .eq("is_archived", false)
        .order("roll_number");
      if (error) throw error;
      return jsonResponse(data ?? []);
    }

    if (action === "details") {
      const studentId = requireString(body.student_id, "student_id");
      if (!allowedStudentIds.includes(studentId)) {
        return jsonResponse({ error: "Not allowed to view this student." }, 403);
      }
      const { data, error } = await supabase
        .from("student_profile_details")
        .select("*")
        .eq("id", studentId)
        .eq("is_archived", false)
        .maybeSingle();
      if (error) throw error;
      if (!data) return jsonResponse({ error: "Student not found." }, 404);
      return jsonResponse(data);
    }

    if (action === "mark_recently_viewed") {
      const studentId = requireString(body.student_id, "student_id");
      if (!allowedStudentIds.includes(studentId)) {
        return jsonResponse({ error: "Not allowed to view this student." }, 403);
      }
      return jsonResponse({ ok: true });
    }

    return jsonResponse({ error: "Unsupported student action." }, 400);
  } catch (error) {
    return jsonResponse(
      { error: error.message ?? "Student request failed." },
      500,
    );
  }
});

async function studentIdsForIdentity(
  supabase: ReturnType<typeof serviceClient>,
  identityId: string,
  role: string,
): Promise<string[]> {
  if (role === "parent") {
    const { data, error } = await supabase
      .from("student_guardians")
      .select("student_id")
      .eq("parent_identity_id", identityId);
    if (error) throw error;
    return (data ?? []).map((row) => row.student_id as string);
  }

  if (role === "student") {
    const { data, error } = await supabase
      .from("student_user_links")
      .select("student_id")
      .eq("student_identity_id", identityId);
    if (error) throw error;
    return (data ?? []).map((row) => row.student_id as string);
  }

  return [];
}
