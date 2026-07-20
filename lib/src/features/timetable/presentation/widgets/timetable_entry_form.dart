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
  String? _classId;
  String? _sectionId;
  String? _subjectId;
  String? _teacherId;
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

  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (controller.text.isNotEmpty) {
      final parts = controller.text.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          initialTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$hourStr:$minuteStr';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_classId == null ||
        _sectionId == null ||
        _subjectId == null ||
        _teacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    // Chronological Boundary Verification
    final startParts = _startTimeController.text.split(':');
    final endParts = _endTimeController.text.split(':');
    if (startParts.length == 2 && endParts.length == 2) {
      final startMinutes = (int.tryParse(startParts[0]) ?? 0) * 60 + (int.tryParse(startParts[1]) ?? 0);
      final endMinutes = (int.tryParse(endParts[0]) ?? 0) * 60 + (int.tryParse(endParts[1]) ?? 0);

      if (endMinutes <= startMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be strictly after start time.')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final entry = TimetableEntry(
        id: widget.entry?.id ?? '',
        classId: _classId!,
        className: '', 
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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timetable period saved successfully.')),
        );
        Navigator.of(context).pop();
      }
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.entry == null ? 'Add Timetable Period' : 'Edit Timetable Period'),
          const SizedBox(height: 4),
          Text(
            'Assign structural class details, teachers, and weekly schedules.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                classes.when(
                  data: (items) => DropdownButtonFormField<String>(
                    initialValue: _classId,
                    decoration: const InputDecoration(
                      labelText: 'Class',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    items: items
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
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
                const SizedBox(height: AppSpacing.md),
                if (_classId != null) ...[
                  sections.when(
                    data: (items) => DropdownButtonFormField<String>(
                      initialValue: _sectionId,
                      decoration: const InputDecoration(
                        labelText: 'Section',
                        prefixIcon: Icon(Icons.layers_outlined),
                      ),
                      items: items
                          .where((s) => s.classId == _classId)
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _sectionId = value),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error loading sections'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                subjects.when(
                  data: (items) => DropdownButtonFormField<String>(
                    initialValue: _subjectId,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    items: items
                        .where(
                          (s) => _classId == null || s.classIds.contains(_classId),
                        )
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _subjectId = value),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading subjects'),
                ),
                const SizedBox(height: AppSpacing.md),
                teachers.when(
                  data: (items) => DropdownButtonFormField<String>(
                    initialValue: _teacherId,
                    decoration: const InputDecoration(
                      labelText: 'Teacher',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: items
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _teacherId = value),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error loading teachers'),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<int>(
                  initialValue: _dayOfWeek,
                  decoration: const InputDecoration(
                    labelText: 'Day of Week',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
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
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startTimeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          prefixIcon: Icon(Icons.schedule),
                        ),
                        onTap: () => _selectTime(_startTimeController),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _endTimeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          prefixIcon: Icon(Icons.schedule),
                        ),
                        onTap: () => _selectTime(_endTimeController),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                    labelText: 'Room (Optional)',
                    prefixIcon: Icon(Icons.meeting_room_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _submit,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save_outlined, size: 18),
          label: Text(_isSaving ? 'Saving...' : 'Save Period'),
        ),
      ],
    );
  }
}