import 'package:flutter/material.dart';
import '../widgets/premium_excel_import_widgets.dart';

class ExcelImportWizardScreen extends StatefulWidget {
  const ExcelImportWizardScreen({super.key});

  @override
  State<ExcelImportWizardScreen> createState() => _ExcelImportWizardScreenState();
}

class _ExcelImportWizardScreenState extends State<ExcelImportWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<Widget> _steps = const [
    StepDownloadTemplate(),
    StepSelectFile(),
    StepColumnMapping(),
    StepValidation(),
    StepPreview(),
    StepImportSummary(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Students')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: WizardStepIndicator(currentStep: _currentStep, totalSteps: _steps.length),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (step) => setState(() => _currentStep = step),
              children: _steps,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: _currentStep > 0 
                      ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                      : null,
                  child: const Text('Previous'),
                ),
                FilledButton(
                  onPressed: _currentStep < _steps.length - 1
                      ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                      : () => Navigator.pop(context),
                  child: Text(_currentStep < _steps.length - 1 ? 'Next' : 'Finish'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
