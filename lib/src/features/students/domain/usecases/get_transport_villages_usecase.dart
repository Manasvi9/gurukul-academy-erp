import '../../../../core/models/result.dart';
import '../entities/transport_village.dart';
import '../repositories/student_repository.dart';

final class GetTransportVillagesUseCase {
  const GetTransportVillagesUseCase(this._repository);

  final StudentRepository _repository;

  Future<Result<List<TransportVillage>>> call() {
    return _repository.transportVillages();
  }
}
