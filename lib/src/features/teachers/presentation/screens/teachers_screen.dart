import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../domain/entities/teacher.dart';
import '../providers/teacher_providers.dart';

final class TeachersScreen extends ConsumerWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachers = ref.watch(teachersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _form(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text('Add teacher'),
      ),
      body: ResponsivePage(
        maxWidth: 1000,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search name or employee ID',
                ),
                onChanged: (value) =>
                    ref.read(teacherSearchProvider.notifier).state = value,
              ),
              const SizedBox(height: AppSpacing.md),
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
                                        (teacher) => ListTile(
                                          title: Text(teacher.fullName),
                                          subtitle: Text(teacher.employeeId),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _form(
                                              context,
                                              ref,
                                              teacher: teacher,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Employee ID')),
                                      DataColumn(label: Text('Name')),
                                      DataColumn(label: Text('Email')),
                                      DataColumn(label: Text('Actions')),
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
        title: Text(teacher == null ? 'Add Teacher' : 'Edit Teacher'),
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
                decoration: const InputDecoration(labelText: 'Employee ID'),
              ),
              TextFormField(
                controller: name,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required.' : null,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
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
        title: const Text('Archive teacher?'),
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
