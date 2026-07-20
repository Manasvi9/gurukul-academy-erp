import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Role Permission Configuration ---
enum AppPermission {
  addStudent,
  importStudents,
  deleteStudent,
  bulkActions,
  editStudent,
  viewFees,
  viewAttendance,
  viewResults,
  generateID,
}

Map<String, Set<AppPermission>> rolePermissions = {
  'systemAdmin': {AppPermission.addStudent, AppPermission.importStudents, AppPermission.deleteStudent, AppPermission.bulkActions, AppPermission.editStudent, AppPermission.viewFees, AppPermission.viewAttendance, AppPermission.viewResults, AppPermission.generateID},
  'director': {AppPermission.addStudent, AppPermission.importStudents, AppPermission.deleteStudent, AppPermission.bulkActions, AppPermission.editStudent, AppPermission.viewFees, AppPermission.viewAttendance, AppPermission.viewResults, AppPermission.generateID},
  'principal': {AppPermission.addStudent, AppPermission.importStudents, AppPermission.deleteStudent, AppPermission.bulkActions, AppPermission.editStudent, AppPermission.viewFees, AppPermission.viewAttendance, AppPermission.viewResults, AppPermission.generateID},
  'teacher': {AppPermission.viewAttendance, AppPermission.viewResults},
  'parent': {AppPermission.viewFees, AppPermission.viewAttendance, AppPermission.viewResults},
  'student': {AppPermission.viewAttendance, AppPermission.viewResults},
};

// --- Reusable Student UI Components ---
class StudentListTile extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onTap;

  const StudentListTile({super.key, required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text(student['name'][0])),
        title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${student['class']} | Roll: ${student['roll']}'),
        trailing: Chip(
          label: Text(student['status']),
          backgroundColor: student['status'] == 'Active' ? Colors.green.shade50 : Colors.red.shade50,
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isFilled;

  const ActionButton({super.key, required this.label, required this.icon, required this.onPressed, this.isFilled = false});

  @override
  Widget build(BuildContext context) {
    return isFilled
        ? FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label))
        : OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label));
  }
}

// Profile Specific Widgets
class InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? trailing;

  const InfoCard({super.key, required this.title, required this.children, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (trailing != null) trailing!,
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const InfoRow({super.key, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600])),
            Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: onTap != null ? Colors.blue : Colors.black)),
          ],
        ),
      ),
    );
  }
}

class StudentTimeline extends StatelessWidget {
  const StudentTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final events = ['Admission Completed', 'Attendance Updated', 'Fee Paid'];
    return Column(
      children: events.map((e) => ListTile(
        leading: const Icon(Icons.circle, size: 12),
        title: Text(e),
        dense: true,
      )).toList(),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onViewAll;

  const SummaryCard({super.key, required this.title, required this.value, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20)),
            TextButton(onPressed: onViewAll, child: const Text('View All')),
          ],
        ),
      ),
    );
  }
}

class DocumentTile extends StatelessWidget {
  final String name;

  const DocumentTile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.description),
      title: Text(name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.visibility), onPressed: () {}),
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const AppEmptyState({super.key, required this.message, this.icon = Icons.info_outline});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class StudentProfileShimmer extends StatelessWidget {
  const StudentProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Container(
        height: 100,
        color: Colors.grey[200],
      ),
    );
  }
}
