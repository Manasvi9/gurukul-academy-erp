import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../app/bootstrap/app_bootstrap.dart';
import '../data/certificate_repository.dart';
import '../domain/entities/certificate.dart';
import '../domain/repositories/certificate_repository.dart';

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  return SupabaseCertificateRepository(ref.watch(supabaseClientProvider));
});

final certificatesListProvider = FutureProvider.autoDispose<List<Certificate>>((
  ref,
) {
  return ref.watch(certificateRepositoryProvider).list();
});

final certificateDetailsProvider =
    FutureProvider.autoDispose.family<Certificate, String>((
  ref,
  certificateId,
) {
  return ref.watch(certificateRepositoryProvider).getById(certificateId);
});

final createCertificateControllerProvider = StateNotifierProvider.autoDispose<
    CreateCertificateController,
    AsyncValue<void>>((ref) {
  return CreateCertificateController(ref.watch(certificateRepositoryProvider));
});

final class CreateCertificateController extends StateNotifier<AsyncValue<void>> {
  CreateCertificateController(this._repository)
      : super(const AsyncValue.data(null));

  final CertificateRepository _repository;

  Future<bool> create(Certificate certificate) async {
    state = const AsyncValue.loading();
    try {
      await _repository.create(certificate);
      state = const AsyncValue.data(null);
      return true;
    } on Object catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}
