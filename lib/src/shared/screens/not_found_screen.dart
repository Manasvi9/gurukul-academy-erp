import 'package:flutter/material.dart';

final class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gurukul Academy')),
      body: const Center(
        child: Text('Page not found.'),
      ),
    );
  }
}
