# Student Management

## Scope

This module implements Student Management only:

- Global student search.
- Browse by academic year, class, and section.
- Compact student list.
- Student details with profile tabs.
- Add/edit student wizard.
- Archive student instead of permanent delete.
- Transport village master usage.
- Fee structure lookup for admission-time calculation.

Fees, attendance, marks, and transfer certificate business modules are not implemented here. Student profile tabs only show available summary values or direct the user to the owning future module.

## Security

Flutter is not trusted for permissions. Client-side role checks are UX only.

Staff users use Supabase Auth and direct PostgREST access protected by RLS.

Parent and student users use custom authentication sessions, so their student reads go through the `student-access` Edge Function. That function verifies the custom JWT and resolves allowed students through `student_guardians` and `student_user_links`.

## Backend Rules

The backend enforces:

- Archived students are hidden from normal lists.
- Admin, Director, and Principal can create, update, and archive students.
- Teachers can view only assigned classes.
- Parents can view only linked children.
- Students can view only their own profile.
- Transport fee is calculated from the selected village.
- Student SR number remains manually entered and unique.
