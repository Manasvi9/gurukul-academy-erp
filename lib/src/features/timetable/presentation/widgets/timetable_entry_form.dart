import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gurukul_academy_erp/src/core/theme/app_spacing.dart';
import 'package:gurukul_academy_erp/src/features/academic_structure/presentation/providers/academic_structure_providers.dart';
import 'package:gurukul_academy_erp/src/features/timetable/domain/entities/timetable_entry.dart';
import 'package:gurukul_academy_erp/src/features/timetable/presentation/timetable_providers.dart';

class TimetableEntryForm extends ConsumerStatefulWidget {
  const TimetableEntryForm({super.key, this.entry});

  final TimetableEntry? entry;

  @override
  ConsumerState<TimetableEntryForm> createState() => _TimetableEntryFormState();
}

class _TimetableEntryFormState extends ConsumerState<TimetableEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late String? _classId;
  late String? _sectionId;
  late String? _subjectId;
  late String? _teacherId;
  late int _dayOfWeek;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;
  late final TextEditingController _roomController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _classId = widget.entry?.classId;
    _sectionId = widget.entry?.sectionId;
    _subjectId = widget.entry?.subjectId;
    _teacherId = widget.entry?.teacherId;
    _dayOfWeek = widget.entry?.dayOfWeek ?? 1;
    _startTimeController =
        TextEditingController(text: widget.entry?.startTime ?? '09:00');
    _endTimeController =
        TextEditingController(text: widget.entry?.endTime ?? '09:45');
    _roomController = TextEditingController(text: widget.entry?.room ?? '');
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_classId == null ||
        _sectionId == null ||
        _subjectId == null ||
        _teacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final entry = TimetableEntry(
        id: widget.entry?.id ?? '',
        classId: _classId!,
        className: '', // Not used for saving
        sectionId: _sectionId!,
        sectionName: '',
        subjectId: _subjectId!,
        subjectName: '',
        teacherId: _teacherId!,
        teacherName: '',
        dayOfWeek: _dayOfWeek,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        room: _roomController.text.isEmpty ? null : _roomController.text,
      );

      await ref.read(timetableRepositoryProvider).save(entry);
      ref.invalidate(timetableEntriesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classes = ref.watch(activeAcademicClassesProvider);
    final subjects = ref.watch(academicSubjectsProvider);
    final teachers = ref.watch(timetableTeachersProvider);
    final sections = ref.watch(academicSectionsProvider);

    return AlertDialog(
      title: Text(widget.entry == null
          ? 'Add Timetable Period'
          : 'Edit Timetable Period',),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              classes.when(
                data: (items) => DropdownButtonFormField<String>(
                  initialValue: _classId,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: items
                      .map((item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),)
                      .toList(),
                  onChanged: (value) => setState(() {
                    _classId = value;
                    _sectionId = null;
                  }),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading classes'),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_classId != null)
                sections.when(
                  data: (items) => DropdownButtonFormField<String>(
                    initialValue: _sectionId,
                    decoration: const InputDecoration(labelText: 'Section'),
                    items: items
                        .where((s) => s.classId == _classId)
                        .map((item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),)
                        .toList(),
                    onChanged: (value) => setState(() => _sectionId = value),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading sections'),
                ),
              const SizedBox(height: AppSpacing.sm),
              subjects.when(
                data: (items) => DropdownButtonFormField<String>(
                  initialValue: _subjectId,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: items
                      .where((s) =>
                          _classId == null || s.classIds.contains(_classId),)
                      .map((item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),)
                      .toList(),
                  onChanged: (value) => setState(() => _subjectId = value),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading subjects'),
              ),
              const SizedBox(height: AppSpacing.sm),
              teachers.when(
                data: (items) => DropdownButtonFormField<String>(
                  initialValue: _teacherId,
                  decoration: const InputDecoration(labelText: 'Teacher'),
                  items: items
                      .map((item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),)
                      .toList(),
                  onChanged: (value) => setState(() => _teacherId = value),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading teachers'),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<int>(
                initialValue: _dayOfWeek,
                decoration: const InputDecoration(labelText: 'Day of Week'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Monday')),
                  DropdownMenuItem(value: 2, child: Text('Tuesday')),
                  DropdownMenuItem(value: 3, child: Text('Wednesday')),
                  DropdownMenuItem(value: 4, child: Text('Thursday')),
                  DropdownMenuItem(value: 5, child: Text('Friday')),
                  DropdownMenuItem(value: 6, child: Text('Saturday')),
                  DropdownMenuItem(value: 7, child: Text('Sunday')),
                ],
                onChanged: (value) => setState(() => _dayOfWeek = value!),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        hintText: 'HH:MM',
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        hintText: 'HH:MM',
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room (Optional)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
