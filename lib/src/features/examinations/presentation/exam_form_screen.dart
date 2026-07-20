import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_async_view.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../../students/domain/entities/academic_year.dart';
import '../../students/domain/entities/class_section.dart';
import '../../students/domain/entities/school_class.dart';
import '../../students/presentation/providers/student_providers.dart';
import '../domain/entities/exam.dart';
import 'exam_providers.dart';

final class ExamFormScreen extends ConsumerStatefulWidget {
  const ExamFormScreen({this.examId, super.key});

  final String? examId;

  bool get isEditing => examId != null;

  @override
  ConsumerState<ExamFormScreen> createState() => _ExamFormScreenState();
}

final class _ExamFormScreenState extends ConsumerState<ExamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  ExamType _type = ExamType.unitTest;
  ExamStatus _status = ExamStatus.draft;
  String? _academicYearId;
  String? _classId;
  String? _sectionId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _loadedEditData = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadEditData(Exam exam) {
    if (_loadedEditData) return;
    _nameController.text = exam.name;
    _descriptionController.text = exam.description ?? '';
    _type = exam.type;
    _status = exam.status;
    _academicYearId = exam.academicYearId;
    _classId = exam.classId;
    _sectionId = exam.sectionId;
    _startDate = exam.startDate;
    _endDate = exam.endDate;
    _loadedEditData = true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.examId != null) {
      final examsAsync = ref.watch(examsProvider);
      return AppAsyncView<List<Exam>>(
        value: examsAsync,
        data: (exams) {
          final exam = exams.firstWhere(
            (e) => e.id == widget.examId,
            orElse: () => throw Exception('Exam not found'),
          );
          _loadEditData(exam);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final academicYearsAsync = ref.watch(academicYearsProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing ? "Edit Examination" : "Create Examination",
            ),
            Text(
              "Exam schedule & configuration",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ResponsivePage(
        maxWidth: 720,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Exam Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Exam Name',
                        prefixIcon: Icon(Icons.assignment),
                        fillColor: Color(0xFFF9F9F9),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please enter exam name'
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Exam Type
                    DropdownButtonFormField<ExamType>(
                      initialValue: _type,
                      decoration: const InputDecoration(
                        labelText: 'Exam Type',
                        prefixIcon: Icon(Icons.category),
                        fillColor: Color(0xFFF9F9F9),
                      ),
                      items: ExamType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _type = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Academic Year (Async Dropdown)
                    AppAsyncView<List<AcademicYear>>(
                      value: academicYearsAsync,
                      data: (years) {
                        return DropdownButtonFormField<String>(
                          initialValue: _academicYearId,
                          decoration: const InputDecoration(
                            labelText: 'Academic Year',
                            prefixIcon: Icon(Icons.calendar_today),
                            fillColor: Color(0xFFF9F9F9),
                          ),
                          items: years.map((y) {
                            return DropdownMenuItem(
                              value: y.id,
                              child: Text(y.name),
                            );
                          }).toList(),
                          validator: (value) => value == null
                              ? 'Academic year is required'
                              : null,
                          onChanged: (value) {
                            setState(() {
                              _academicYearId = value;
                              _classId = null;
                              _sectionId = null;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Class (Dependent on Academic Year)
                    if (_academicYearId != null)
                      AppAsyncView<List<SchoolClass>>(
                        value: ref.watch(classesProvider(_academicYearId!)),
                        data: (classes) {
                          return DropdownButtonFormField<String>(
                            initialValue: _classId,
                            decoration: const InputDecoration(
                              labelText: 'Class',
                              prefixIcon: Icon(Icons.class_),
                              fillColor: Color(0xFFF9F9F9),
                            ),
                            items: classes.map((c) {
                              return DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              );
                            }).toList(),
                            validator: (value) =>
                                value == null ? 'Class is required' : null,
                            onChanged: (value) {
                              setState(() {
                                _classId = value;
                                _sectionId = null;
                              });
                            },
                          );
                        },
                      ),
                    if (_academicYearId != null)
                      const SizedBox(height: AppSpacing.md),

                    // Section (Dependent on Class)
                    if (_classId != null)
                      AppAsyncView<List<ClassSection>>(
                        value: ref.watch(sectionsProvider(_classId!)),
                        data: (sections) {
                          return DropdownButtonFormField<String>(
                            initialValue: _sectionId,
                            decoration: const InputDecoration(
                              labelText: 'Section',
                              prefixIcon: Icon(Icons.grid_view),
                              fillColor: Color(0xFFF9F9F9),
                            ),
                            items: sections.map((s) {
                              return DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              );
                            }).toList(),
                            validator: (value) =>
                                value == null ? 'Section is required' : null,
                            onChanged: (value) {
                              setState(() => _sectionId = value);
                            },
                          );
                        },
                      ),
                    if (_classId != null) const SizedBox(height: AppSpacing.md),

                    // Start Date Picker
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(isStart: true),
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                                prefixIcon: Icon(Icons.date_range),
                                fillColor: Color(0xFFF9F9F9),
                              ),
                              child: Text(
                                _startDate != null
                                    ? DateFormat('dd MMM yyyy')
                                        .format(_startDate!)
                                    : 'Select Date',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // End Date Picker
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(isStart: false),
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Date (Optional)',
                                prefixIcon: Icon(Icons.date_range_outlined),
                                fillColor: Color(0xFFF9F9F9),
                              ),
                              child: Text(
                                _endDate != null
                                    ? DateFormat('dd MMM yyyy')
                                        .format(_endDate!)
                                    : 'Select Date',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Exam Instructions',
                        hintText:
                            'Add notes, instructions or additional information...',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.description),
                        fillColor: Color(0xFFF9F9F9),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Status (Draft/Published/Archived)
                    DropdownButtonFormField<ExamStatus>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.star_half),
                        fillColor: Color(0xFFF9F9F9),
                      ),
                      items: ExamStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _status = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            onPressed: () => context.pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFFECE0),
                              foregroundColor: const Color(0xFF8B4F30),
                              side: const BorderSide(color: Color(0xFFFFCCAC)),
                            ),
                            onPressed: _isSaving ? null : _save,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Color(0xFF8B4F30),
                                      ),
                                    ),
                                  )
                                : Text(
                                    widget.isEditing
                                        ? "Save Changes"
                                        : "Create Examination",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Ensure end date is after start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start Date is required')),
      );
      return;
    }

    if (_endDate != null && _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End Date must be on or after Start Date'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final values = {
        'name': _nameController.text.trim(),
        'type': _type.value,
        'academic_year_id': _academicYearId,
        'class_id': _classId,
        'section_id': _sectionId,
        'start_date': _startDate!.toIso8601String().split('T')[0],
        'end_date': _endDate?.toIso8601String().split('T')[0],
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'status': _status.value,
      };

      if (widget.isEditing) {
        await ref.read(examUpdateProvider)(widget.examId!, values);
      } else {
        await ref.read(examCreateProvider)(values);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Examination updated successfully'
                  : 'Examination created successfully',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Unable to save examination.\n$e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
