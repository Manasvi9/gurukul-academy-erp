import {
  jsonResponse,
  preflight,
  requireString,
  serviceClient,
  verifyJwt,
} from "../_shared/custom_auth.ts";

type StudentProfile = {
  id: string;
  student_name: string;
  sr_number: string;
  academic_year_id: string;
  academic_year: string;
  class_id: string;
  class_name: string;
  section_id: string;
  section_name: string;
  attendance_percentage: number | null;
  fee_due: number;
};

Deno.serve(async (request) => {
  const preflightResponse = preflight(request);
  if (preflightResponse) return preflightResponse;

  try {
    const authorization = request.headers.get("Authorization") ?? "";
    const token = authorization.replace("Bearer ", "");
    const payload = await verifyJwt(token);
    const identityId = requireString(payload.sub, "sub");
    const role = requireString(payload.role, "role");

    if (role !== "parent" && role !== "student") {
      return jsonResponse({ error: "Unsupported dashboard role." }, 403);
    }

    return jsonResponse(await customDashboard(role, identityId));
  } catch (error) {
    return jsonResponse(
      { error: error.message ?? "Dashboard request failed." },
      500,
    );
  }
});

async function customDashboard(role: string, identityId: string) {
  const supabase = serviceClient();
  const linkTable = role === "parent" ? "student_guardians" : "student_user_links";
  const linkColumn = role === "parent" ? "parent_identity_id" : "student_identity_id";
  const { data: links, error: linksError } = await supabase
    .from(linkTable)
    .select("student_id")
    .eq(linkColumn, identityId);
  if (linksError) throw linksError;

  const studentIds = (links ?? []).map((link) => link.student_id as string);
  const notifications = await recentNotifications(supabase);
  if (studentIds.length === 0) {
    return emptyDashboard(role, notifications);
  }

  const { data: profileRows, error: profilesError } = await supabase
    .from("student_profile_details")
    .select(
      "id, student_name, sr_number, academic_year_id, academic_year, class_id, class_name, section_id, section_name, attendance_percentage, fee_due",
    )
    .in("id", studentIds)
    .eq("is_archived", false);
  if (profilesError) throw profilesError;
  const profiles = (profileRows ?? []) as StudentProfile[];

  const [attendance, homework, results, fees, exams] = await Promise.all([
    todayAttendance(supabase, studentIds),
    upcomingHomework(supabase, profiles),
    recentResults(supabase, studentIds),
    feeStatus(supabase, profiles),
    upcomingExams(supabase, profiles),
  ]);

  const isParent = role === "parent";
  return {
    role,
    title: isParent ? "Parent Dashboard" : "Student Dashboard",
    cards: [
      metric(
        "profile",
        isParent ? "Children" : "My Profile",
        isParent ? String(profiles.length) : profiles[0]?.student_name ?? "Unavailable",
        isParent ? "groups" : "person",
        "/students",
      ),
      metric("attendance", "Today's Attendance", attendance.summary, "fact_check", null),
      metric("homework", "Homework", String(homework.length), "assignment", null),
      metric("results", "Recent Results", String(results.length), "grading", null),
      metric("fees", "Fee Status", fees.summary, "payments", null),
      metric("upcoming_exams", "Upcoming Exams", String(exams.length), "event", null),
    ],
    notifications,
    sections: [
      section(
        isParent ? "Child Profile Summary" : "Personal Profile",
        isParent ? "No child profile is linked to this account." : "Your profile is not available.",
        profiles.map((profile) => activity(
          profile.id,
          profile.student_name,
          "${profile.class_name} ${profile.section_name} • SR ${profile.sr_number}",
        )),
      ),
      section("Today's Attendance", "Attendance has not been marked today.", attendance.items),
      section("Homework", "No upcoming homework.", homework),
      section("Recent Exam Results", "No finalised exam results are available.", results),
      section("Fee Status", "No fee information is available.", fees.items),
      section("Upcoming Exams", "No upcoming exams are scheduled.", exams),
      section("Timetable", "Timetable is not available for this class.", []),
    ],
  };
}

async function recentNotifications(supabase: ReturnType<typeof serviceClient>) {
  const { data, error } = await supabase
    .from("notifications")
    .select("id, title, description, created_at")
    .eq("is_archived", false)
    .lte("published_on", new Date().toISOString().slice(0, 10))
    .order("published_on", { ascending: false })
    .order("created_at", { ascending: false })
    .limit(5);
  if (error) throw error;
  return (data ?? []).map((notice) => ({
    id: notice.id,
    title: notice.title,
    message: notice.description,
    created_at: notice.created_at,
  }));
}

async function todayAttendance(supabase: ReturnType<typeof serviceClient>, studentIds: string[]) {
  const today = new Date().toISOString().slice(0, 10);
  const { data, error } = await supabase
    .from("student_attendance_history")
    .select("student_id, student_name, status")
    .in("student_id", studentIds)
    .eq("attendance_date", today);
  if (error) throw error;
  const items = (data ?? []).map((row) => activity(
    `${row.student_id}-${today}`,
    row.student_name,
    `Status: ${String(row.status).replaceAll("_", " ")}`,
  ));
  const present = (data ?? []).filter((row) => row.status === "present" || row.status === "late").length;
  return {
    summary: items.length === 0 ? "Not marked" : `${present}/${items.length} present`,
    items,
  };
}

async function upcomingHomework(supabase: ReturnType<typeof serviceClient>, profiles: StudentProfile[]) {
  const today = new Date().toISOString().slice(0, 10);
  const responses = await Promise.all(profiles.map((profile) => supabase
    .from("homework_details")
    .select("id, subject_name, due_date, description, class_name, section_name")
    .eq("academic_year_id", profile.academic_year_id)
    .eq("class_id", profile.class_id)
    .eq("section_id", profile.section_id)
    .gte("due_date", today)
    .order("due_date")
    .limit(5)));
  const rows = responses.flatMap((response) => {
    if (response.error) throw response.error;
    return response.data ?? [];
  });
  return uniqueActivities(rows.map((row) => activity(
    row.id,
    row.subject_name,
    `${row.class_name} ${row.section_name} • Due ${row.due_date}: ${row.description}`,
  )));
}

async function recentResults(supabase: ReturnType<typeof serviceClient>, studentIds: string[]) {
  const { data, error } = await supabase
    .from("exam_marks")
    .select("id, marks, is_final, updated_at, exam_subjects(subjects(name), exams(name, start_date, status, is_archived))")
    .in("student_id", studentIds)
    .eq("is_final", true)
    .order("updated_at", { ascending: false })
    .limit(10);
  if (error) throw error;
  return (data ?? []).flatMap((row) => {
    const subject = row.exam_subjects?.subjects?.name as string | undefined;
    const exam = row.exam_subjects?.exams;
    if (!subject || !exam || exam.status !== "published" || exam.is_archived) return [];
    return [activity(row.id, `${exam.name} • ${subject}`, row.marks == null ? "Absent" : `Marks: ${row.marks}`)];
  });
}

async function feeStatus(supabase: ReturnType<typeof serviceClient>, profiles: StudentProfile[]) {
  const items = await Promise.all(profiles.map(async (profile) => {
    const { data, error } = await supabase
      .from("student_fee_ledger")
      .select("student_name, paid_amount, outstanding_due, is_fee_complete")
      .eq("student_id", profile.id)
      .eq("academic_year_id", profile.academic_year_id)
      .maybeSingle();
    if (error) throw error;
    if (!data) return null;
    const isPaid = data.is_fee_complete || Number(data.outstanding_due) <= 0;
    return activity(
      profile.id,
      data.student_name,
      isPaid
        ? `Paid • ₹${data.paid_amount}`
        : `Pending ₹${data.outstanding_due} • Paid ₹${data.paid_amount}`,
    );
  }));
  const availableItems = items.filter((item) => item !== null);
  const pending = availableItems.filter((item) => item.subtitle.startsWith("Pending")).length;
  return {
    summary: pending === 0 ? "Paid" : `${pending} pending`,
    items: availableItems,
  };
}

async function upcomingExams(supabase: ReturnType<typeof serviceClient>, profiles: StudentProfile[]) {
  const today = new Date().toISOString().slice(0, 10);
  const responses = await Promise.all(profiles.map((profile) => supabase
    .from("exams")
    .select("id, name, start_date, end_date")
    .eq("academic_year_id", profile.academic_year_id)
    .eq("class_id", profile.class_id)
    .eq("section_id", profile.section_id)
    .eq("status", "published")
    .eq("is_archived", false)
    .gte("start_date", today)
    .order("start_date")
    .limit(5)));
  const rows = responses.flatMap((response) => {
    if (response.error) throw response.error;
    return response.data ?? [];
  });
  return uniqueActivities(rows.map((row) => activity(
    row.id,
    row.name,
    `Starts ${row.start_date}${row.end_date ? ` • Ends ${row.end_date}` : ""}`,
  )));
}

function emptyDashboard(role: string, notifications: unknown[]) {
  return {
    role,
    title: role === "parent" ? "Parent Dashboard" : "Student Dashboard",
    cards: [],
    notifications,
    sections: [section("Profile", "No student profile is linked to this account.", [])],
  };
}

function uniqueActivities(items: Array<{ id: string; title: string; subtitle: string }>) {
  return [...new Map(items.map((item) => [item.id, item])).values()];
}

function section(title: string, emptyMessage: string, items: unknown[]) {
  return { title, empty_message: emptyMessage, items };
}

function activity(id: string, title: string, subtitle: string) {
  return { id, title, subtitle };
}

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
