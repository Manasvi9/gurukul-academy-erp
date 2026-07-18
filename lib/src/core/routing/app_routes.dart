enum AppRoute {
  login('/login'),
  changePassword('/change-password'),
  adminDashboard('/admin-dashboard'),
  directorDashboard('/director-dashboard'),
  principalDashboard('/principal-dashboard'),
  teacherDashboard('/teacher-dashboard'),
  parentDashboard('/parent-dashboard'),
  studentDashboard('/student-dashboard'),
  students('/students'),
  teachers('/teachers'),
  classes('/academic-structure/classes'),
  sections('/academic-structure/sections'),
  subjects('/academic-structure/subjects'),
  addStudent('/students/add'),
  studentSearch('/students/search'),
  studentClasses('/students/classes'),
  studentClassSections('/students/classes/:classId/sections'),
  studentList('/students/classes/:classId/sections/:sectionId'),
  studentDetails('/students/:studentId'),
  editStudent('/students/:studentId/edit'),
  fees('/fees'),
  feeSearch('/fees/search'),
  feeStudentLedger('/fees/students/:studentId'),
  homework('/homework'),
  exams('/exams'),
  notFound('/not-found');

  const AppRoute(this.path);

  final String path;
}
