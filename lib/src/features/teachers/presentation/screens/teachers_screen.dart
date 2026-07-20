import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../domain/entities/teacher.dart';
import '../providers/teacher_providers.dart';

final class TeachersScreen extends ConsumerStatefulWidget {
  const TeachersScreen({super.key});

  @override
  ConsumerState<TeachersScreen> createState() => _TeachersScreenState();
}

final class _TeachersScreenState extends ConsumerState<TeachersScreen> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teachers = ref.watch(teachersProvider);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Teachers'),
            Text(
              'Manage teaching staff',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _form(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Teacher'),
      ),
      body: ResponsivePage(
        maxWidth: 1000,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by teacher name or employee ID',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Icon(Icons.manage_search_outlined),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: AppAsyncView(
                  value: teachers,
                  data: (items) => items.isEmpty
                      ? const AppEmptyView(
                          title: 'No teachers',
                          message: 'Add a teacher to get started.',
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) => constraints
                                      .maxWidth <
                                  600
                              ? ListView(
                                  children: items
                                      .map(
                                        (teacher) => Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              teacher.fullName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            subtitle: Text(
                                              'Employee ID • ${teacher.employeeId}',
                                            ),
                                            leading: const CircleAvatar(
                                              child: Icon(Icons.person_outline),
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () => _form(
                                                context,
                                                ref,
                                                teacher: teacher,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Card(
  elevation: 2,
  clipBehavior: Clip.antiAlias,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: DataTable(
                                    columns: const [
                                      DataColumn(
  label: Text(
    'Employee ID',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
),
DataColumn(
  label: Text(
    'Name',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
),
DataColumn(
  label: Text(
    'Email',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
),
DataColumn(
  label: Text(
    'Actions',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
),
                                    ],
                                    rows: items
                                        .map(
                                          (teacher) => DataRow(
                                            cells: [
                                              DataCell(
                                                Text(teacher.employeeId),
                                              ),
                                              DataCell(Text(teacher.fullName)),
                                              DataCell(
                                                Text(teacher.email ?? '-'),
                                              ),
                                              DataCell(
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                      ),
                                                      onPressed: () => _form(
                                                        context,
                                                        ref,
                                                        teacher: teacher,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.archive_outlined,
                                                      ),
                                                      onPressed: () => _archive(
                                                        context,
                                                        ref,
                                                        teacher,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _form(
    BuildContext context,
    WidgetRef ref, {
    Teacher? teacher,
  }) async {
    final key = GlobalKey<FormState>();
    final employee = TextEditingController(text: teacher?.employeeId);
    final name = TextEditingController(text: teacher?.fullName);
    final email = TextEditingController(text: teacher?.email);
    await showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Row(
  children: [
    Icon(
      teacher == null
          ? Icons.person_add_alt_1
          : Icons.edit_outlined,
    ),
    const SizedBox(width: 10),
    Text(
      teacher == null
          ? 'Add Teacher'
          : 'Edit Teacher',
    ),
  ],
),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: employee,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Employee ID is required.'
                    : null,
                decoration: const InputDecoration(
  labelText: 'Employee ID',
  prefixIcon: Icon(Icons.badge_outlined),
),
              ),
              TextFormField(
                controller: name,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required.' : null,
                decoration: const InputDecoration(labelText: 'Name',prefixIcon: Icon(Icons.person_outline),),
                
              ),
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email',prefixIcon: Icon(Icons.email_outlined),),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!key.currentState!.validate()) return;
              try {
                await ref.read(teacherRepositoryProvider).save(
                      id: teacher?.id,
                      employeeId: employee.text,
                      fullName: name.text,
                      email: email.text,
                    );
                ref.invalidate(teachersProvider);
                if (dialog.mounted) {
                  Navigator.pop(dialog);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teacher saved successfully.'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    Teacher teacher,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Row(
  children: [
    Icon(Icons.archive_outlined),
    SizedBox(width: 10),
    Text('Archive Teacher'),
  ],
),
        content: Text(
          '${teacher.fullName} will be hidden from active lists.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(teacherRepositoryProvider).archive(teacher.id);
      ref.invalidate(teachersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teacher archived successfully.')),
        );
      }
    }
  }
}
