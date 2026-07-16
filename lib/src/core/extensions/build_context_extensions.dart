import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  bool get isCompact => MediaQuery.sizeOf(this).width < 640;
}
