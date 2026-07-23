import 'package:flutter/material.dart';

// --- Custom Wizard Components ---
class WizardStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const WizardStepIndicator({super.key, required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: index == currentStep ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: index <= currentStep ? const Color(0xFF1A237E) : Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),),
    );
  }
}

// --- Import Steps ---
class StepDownloadTemplate extends StatelessWidget {
  const StepDownloadTemplate({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Step 1: Download Template"));
}

class StepSelectFile extends StatelessWidget {
  const StepSelectFile({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Step 2: Select File"));
}

class StepColumnMapping extends StatelessWidget {
  const StepColumnMapping({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Step 3: Column Mapping"));
}

class StepValidation extends StatelessWidget {
  const StepValidation({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Step 4: Row-level Validation"));
}

class StepPreview extends StatelessWidget {
  const StepPreview({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Step 5: Preview Table"));
}

class StepImportSummary extends StatelessWidget {
  const StepImportSummary({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Step 6: Import Summary"));
}
