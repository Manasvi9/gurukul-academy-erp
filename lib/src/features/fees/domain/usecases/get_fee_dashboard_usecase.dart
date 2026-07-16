import '../../../../core/models/result.dart';
import '../entities/student_fee_ledger.dart';
import '../repositories/fee_repository.dart';

final class GetFeeDashboardUseCase {
  const GetFeeDashboardUseCase(this._repository);

  final FeeRepository _repository;

  Future<Result<List<StudentFeeLedger>>> call() {
    return _repository.outstandingLedgers();
  }
}
