import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_error_view.dart';
import 'app_loading_view.dart';

final class AppAsyncView<T> extends StatelessWidget {
  const AppAsyncView({
    required this.value,
    required this.data,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      AsyncData<T>(:final value) => data(value),
      AsyncError<T>(:final error) => AppErrorView(message: error.toString()),
      _ => const AppLoadingView(),
    };
  }
}
