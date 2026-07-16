import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/validation/validators.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../domain/entities/academic_year.dart';
import '../../domain/entities/class_section.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/entities/student_detail.dart';
import '../../domain/entities/student_form_data.dart';
import '../../domain/entities/student_gender.dart';
import '../../domain/entities/transport_village.dart';
import '../providers/student_providers.dart';

final class StudentFormScreen extends ConsumerStatefulWidget {
  const StudentFormScreen({
    this.studentId,
    super.key,
  });

  final String? studentId;

  bool get isEditing => studentId != null;

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

final class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _srController = TextEditingController();
  final _nameController = TextEditingController();
  final _fatherController = TextEditingController();
  final _motherController = TextEditingController();
  final _mobileController = TextEditingController();
  final _discountController = TextEditingController(text: '0');

  DateTime? _admissionDate;
  DateTime? _dateOfBirth;
  StudentGender _gender = StudentGender.male;
  String? _academicYearId;
  String? _classId;
  String? _sectionId;
  bool _usesTransport = false;
  String? _villageId;
  bool _loadedEditData = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _srController.dispose();
    _nameController.dispose();
    _fatherController.dispose();
    _motherController.dispose();
    _mobileController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.studentId != null) {
      final detail = ref.watch(studentDetailsProvider(widget.studentId!));
      return AppAsyncView(
        value: detail,
        data: (student) {
          _loadEditData(student);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final isSaving = ref.watch(saveStudentControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Student' : 'Add Student'),
      ),
      body: ResponsivePage(
        maxWidth: 760,
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 4) {
                setState(() => _currentStep += 1);
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              }
            },
            controlsBuilder: (context, details) {
              final isLast = details.currentStep == 4;
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Row(
                  children: [
                    FilledButton(
                      onPressed: isSaving
                          ? null
                          : isLast
                              ? _save
                              : details.onStepContinue,
                      child: Text(isLast ? 'Save Student' : 'Continue'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (details.currentStep > 0)
                      TextButton(
                        onPressed: isSaving ? null : details.onStepCancel,
                        child: const Text('Back'),
                      ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Student Details'),
                content: _studentDetailsStep(),
                isActive: true,
              ),
              Step(
                title: const Text('Parent Details'),
                content: _parentDetailsStep(),
              ),
              Step(
                title: const Text('Academic Details'),
                content: _academicDetailsStep(),
              ),
              Step(
                title: const Text('Fees'),
                content: _feesStep(),
              ),
              Step(
                title: const Text('Transport & Review'),
                content: _transportStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _studentDetailsStep() {
    return Column(
      children: [
        TextFormField(
          controller: _srController,
          validator: Validators.srNumber,
          decoration: const InputDecoration(labelText: 'SR Number'),
        ),
        const SizedBox(height: AppSpacing.md),
        _DateField(
          label: 'Admission Date',
          value: _admissionDate,
          onChanged: (value) => setState(() => _admissionDate = value),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _nameController,
          validator: (value) => Validators.requiredText(
            value,
            fieldName: 'Student name',
          ),
          decoration: const InputDecoration(labelText: 'Student Name'),
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<StudentGender>(
          value: _gender,
          items: StudentGender.values
              .map(
                (gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender.label),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _gender = value ?? _gender),
          decoration: const InputDecoration(labelText: 'Gender'),
        ),
        const SizedBox(height: AppSpacing.md),
        _DateField(
          label: 'DOB',
          value: _dateOfBirth,
          onChanged: (value) => setState(() => _dateOfBirth = value),
        ),
      ],
    );
  }

  Widget _parentDetailsStep() {
    return Column(
      children: [
        TextFormField(
          controller: _fatherController,
          validator: (value) => Validators.requiredText(
            value,
            fieldName: 'Father name',
          ),
          decoration: const InputDecoration(labelText: 'Father Name'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _motherController,
          validator: (value) => Validators.requiredText(
            value,
            fieldName: 'Mother name',
          ),
          decoration: const InputDecoration(labelText: 'Mother Name'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _mobileController,
          validator: Validators.mobileNumber,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Parent Mobile Number'),
        ),
      ],
    );
  }

  Widget _academicDetailsStep() {
    final years = ref.watch(academicYearsProvider);
    final classes = _academicYearId == null
        ? const AsyncValue<List<SchoolClass>>.data([])
        : ref.watch(classesProvider(_academicYearId!));
    final sections = _classId == null
        ? const AsyncValue<List<ClassSection>>.data([])
        : ref.watch(sectionsProvider(_classId!));

    return Column(
      children: [
        AppAsyncView(
          value: years,
          data: (items) => _dropdown<AcademicYear>(
            label: 'Academic Year',
            value: _findById(items, _academicYearId, (item) => item.id),
            items: items,
            text: (item) => item.name,
            onChanged: (item) {
              setState(() {
                _academicYearId = item?.id;
                _classId = null;
                _sectionId = null;
              });
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppAsyncView(
          value: classes,
          data: (items) => _dropdown<SchoolClass>(
            label: 'Class',
            value: _findById(items, _classId, (item) => item.id),
            items: items,
            text: (item) => item.name,
            onChanged: (item) {
              setState(() {
                _classId = item?.id;
                _sectionId = null;
              });
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppAsyncView(
          value: sections,
          data: (items) => _dropdown<ClassSection>(
            label: 'Section',
            value: _findById(items, _sectionId, (item) => item.id),
            items: items,
            text: (item) => item.name,
            onChanged: (item) => setState(() => _sectionId = item?.id),
          ),
        ),
      ],
    );
  }

  Widget _feesStep() {
    final canLoadFee = _academicYearId != null && _classId != null;
    final fee = canLoadFee
        ? ref.watch(
            feeStructureProvider(
              FeeStructureRequest(
                academicYearId: _academicYearId!,
                classId: _classId!,
              ),
            ),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fee == null)
          const Text('Select academic year and class to load fee structure.')
        else
          AppAsyncView(
            value: fee,
            data: (value) => Text(
              'Class fee: ${value.totalFee.toStringAsFixed(0)}',
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _discountController,
          keyboardType: TextInputType.number,
          validator: _discountValidator,
          decoration: const InputDecoration(labelText: 'Scholarship/Discount'),
        ),
      ],
    );
  }

  Widget _transportStep() {
    final villages = ref.watch(transportVillagesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Uses Transport'),
          value: _usesTransport,
          onChanged: (value) {
            setState(() {
              _usesTransport = value;
              if (!value) {
                _villageId = null;
              }
            });
          },
        ),
        if (_usesTransport)
          AppAsyncView(
            value: villages,
            data: (items) => _dropdown<TransportVillage>(
              label: 'Village',
              value: _findById(items, _villageId, (item) => item.id),
              items: items,
              text: (item) => '${item.name} - ${item.transportFee}',
              onChanged: (item) => setState(() => _villageId = item?.id),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Review details before saving. Fees and transport calculations are validated by the backend.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  DropdownButtonFormField<T> _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T item) text,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: (value) => value == null ? '$label is required.' : null,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(text(item))))
          .toList(),
      onChanged: onChanged,
    );
  }

  T? _findById<T>(
    List<T> items,
    String? id,
    String Function(T item) idOf,
  ) {
    if (id == null) {
      return null;
    }
    for (final item in items) {
      if (idOf(item) == id) {
        return item;
      }
    }
    return null;
  }

  String? _discountValidator(String? value) {
    final required = Validators.requiredText(
      value,
      fieldName: 'Scholarship/discount',
    );
    if (required != null) {
      return required;
    }
    final parsed = num.tryParse(value!);
    if (parsed == null || parsed < 0) {
      return 'Enter a valid discount amount.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_admissionDate == null || _dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admission date and DOB are required.')),
      );
      return;
    }
    if (_usesTransport && _villageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select transport village.')),
      );
      return;
    }

    final data = StudentFormData(
      srNumber: _srController.text,
      admissionDate: _admissionDate!,
      name: _nameController.text,
      gender: _gender,
      dateOfBirth: _dateOfBirth!,
      fatherName: _fatherController.text,
      motherName: _motherController.text,
      parentMobileNumber: _mobileController.text,
      academicYearId: _academicYearId!,
      classId: _classId!,
      sectionId: _sectionId!,
      scholarshipDiscount: num.parse(_discountController.text),
      usesTransport: _usesTransport,
      villageId: _villageId,
    );

    final controller = ref.read(saveStudentControllerProvider.notifier);
    if (widget.studentId == null) {
      final studentId = await controller.create(data);
      if (!mounted || studentId == null) {
        return;
      }
      context.go('/students/$studentId');
      return;
    }

    final saved = await controller.update(
      studentId: widget.studentId!,
      data: data,
    );
    if (!mounted || !saved) {
      return;
    }
    context.go('/students/${widget.studentId}');
  }

  void _loadEditData(StudentDetail student) {
    if (_loadedEditData) {
      return;
    }
    _loadedEditData = true;
    _srController.text = student.srNumber;
    _nameController.text = student.name;
    _fatherController.text = student.fatherName;
    _motherController.text = student.motherName;
    _mobileController.text = student.parentMobileNumber;
    _admissionDate = student.admissionDate;
    _dateOfBirth = student.dateOfBirth;
    _gender = student.gender;
    _academicYearId = student.academicYearId;
    _classId = student.classId;
    _sectionId = student.sectionId;
    _usesTransport = student.usesTransport;
    _villageId = student.villageId;
  }
}

final class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      validator: (_) => value == null ? '$label is required.' : null,
      controller: TextEditingController(
        text: value == null
            ? ''
            : '${value!.day.toString().padLeft(2, '0')}/'
                '${value!.month.toString().padLeft(2, '0')}/${value!.year}',
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_month_outlined),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1990),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
    );
  }
}
