import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/transport_repository.dart';
import '../domain/repositories/transport_repository.dart';

final transportRepositoryProvider = Provider<TransportRepository>((ref) {
  return SupabaseTransportRepository(Supabase.instance.client);
});

final vehiclesProvider = FutureProvider((ref) {
  return ref.watch(transportRepositoryProvider).getVehicles();
});

final routesProvider = FutureProvider((ref) {
  return ref.watch(transportRepositoryProvider).getRoutes();
});
