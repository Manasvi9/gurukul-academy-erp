import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/bootstrap/app_bootstrap.dart';
import 'src/app/gurukul_academy_app.dart';

Future<void> main() async {
  final container = await AppBootstrap.initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const GurukulAcademyApp(),
    ),
  );
}
