import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../providers/student_providers.dart';
import '../widgets/premium_student_widgets.dart';

class StudentDetailsScreen extends ConsumerWidget {
  final String studentId;

  const StudentDetailsScreen({required this.studentId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentDetailsProvider(studentId));
    final authState = ref.watch(authControllerProvider);
    final userRole = authState.user?.role.value ?? '';
    final permissions = rolePermissions[userRole] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          if (permissions.contains(AppPermission.editStudent))
            IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          PopupMenuButton(
            itemBuilder: (context) => [
              if (permissions.contains(AppPermission.generateID))
                const PopupMenuItem(child: Text('Generate ID Card')),
              const PopupMenuItem(child: Text('Print Profile')),
            ],
          ),
        ],
      ),
      body: studentAsync.when(
        loading: () => const StudentProfileShimmer(),
        error: (err, stack) => AppEmptyState(message: 'Error: $err', icon: Icons.error_outline),
        data: (detail) {
          return DefaultTabController(
            length: 6,
            child: Column(
              children: [
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'Attendance'),
                    Tab(text: 'Results'),
                    Tab(text: 'Fees'),
                    Tab(text: 'Homework'),
                    Tab(text: 'Documents'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Overview Tab
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Header
                          Card(
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(detail.name, style: Theme.of(context).textTheme.headlineSmall),
                                            Text('Adm: ${detail.srNumber} | Roll: ${detail.srNumber}'),
                                            Text('${detail.className} | ${detail.sectionName}'),
                                            const Chip(label: Text('Active'), backgroundColor: Colors.greenAccent),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ActionButton(label: 'Call', icon: Icons.call, onPressed: () => launchUrl(Uri.parse('tel:${detail.parentMobileNumber}'))),
                                      ActionButton(label: 'WhatsApp', icon: Icons.message, onPressed: () => launchUrl(Uri.parse('https://wa.me/${detail.parentMobileNumber}'))),
                                      if (permissions.contains(AppPermission.viewAttendance)) ActionButton(label: 'Attendance', icon: Icons.event, onPressed: () {}),
                                      if (permissions.contains(AppPermission.viewFees)) ActionButton(label: 'Fees', icon: Icons.payments, onPressed: () {}),
                                      if (permissions.contains(AppPermission.viewResults)) ActionButton(label: 'Results', icon: Icons.grade, onPressed: () {}),
                                      if (permissions.contains(AppPermission.generateID)) ActionButton(label: 'ID Card', icon: Icons.badge, onPressed: () {}),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Summary Cards
                          Row(
                            children: [
                              Expanded(child: SummaryCard(title: 'Attendance', value: '95%', onViewAll: () {})),
                              const SizedBox(width: 8),
                              Expanded(child: SummaryCard(title: 'Fees Due', value: '500', onViewAll: () {})),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Parent Info
                          InfoCard(title: 'Parent Information', children: [
                            InfoRow(label: 'Father', value: detail.fatherName),
                            InfoRow(label: 'Mother', value: detail.motherName),
                            InfoRow(label: 'Mobile', value: detail.parentMobileNumber, onTap: () => launchUrl(Uri.parse('tel:${detail.parentMobileNumber}'))),
                          ]),
                          // Academic Info
                          InfoCard(title: 'Academic Information', children: [
                            InfoRow(label: 'Admission No', value: detail.srNumber),
                            InfoRow(label: 'Class', value: detail.className),
                          ]),
                          // Timeline
                          const InfoCard(title: 'Timeline', children: [StudentTimeline()]),
                        ],
                      ),
                      const AppEmptyState(message: 'Attendance records not found'),
                      const AppEmptyState(message: 'Result records not found'),
                      const AppEmptyState(message: 'Fee records not found'),
                      const AppEmptyState(message: 'Homework not assigned'),
                      // Documents
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: const [
                          DocumentTile(name: 'Aadhaar.pdf'),
                          DocumentTile(name: 'BirthCertificate.jpg'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
