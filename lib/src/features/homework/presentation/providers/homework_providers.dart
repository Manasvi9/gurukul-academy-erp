import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/bootstrap/app_bootstrap.dart';
import '../../data/repositories/homework_repository.dart';
import '../../domain/entities/homework_item.dart';

final homeworkRepositoryProvider = Provider<HomeworkRepository>(
  (ref) => HomeworkRepository(ref.watch(supabaseClientProvider)),
);

final homeworkListProvider = FutureProvider<List<HomeworkItem>>(
  (ref) => ref.watch(homeworkRepositoryProvider).list(),
);
