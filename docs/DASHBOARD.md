# Dashboard

## Scope

The Dashboard module provides role-specific landing screens for Admin, Director, Principal, Teacher, Parent, and Student users.

## Backend

Staff dashboards use `get_staff_dashboard_summary()` through Supabase Auth. Parent and Student dashboards use the `dashboard-access` Edge Function because those roles use custom authentication sessions.

## Cards

Admin, Director, and Principal dashboards include cards for Students, Teachers, Fees Due, Today's Attendance, Today's Homework, Today's Events, Pending Leave Requests, and Recent Notifications.

Teacher, Parent, and Student dashboards expose the role-specific cards requested by the product flow. Cards route only to modules that already exist.
