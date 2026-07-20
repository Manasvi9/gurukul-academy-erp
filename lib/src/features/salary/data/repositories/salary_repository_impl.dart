import '../../domain/entities/salary_entities.dart';
import '../../domain/entities/salary_payment_enums.dart';
import '../../domain/repositories/salary_repository.dart';
import '../datasources/salary_remote_datasource.dart';
import '../models/salary_models.dart';

final class SalaryRepositoryImpl implements SalaryRepository {
  const SalaryRepositoryImpl(this._datasource);
  final SalaryRemoteDatasource _datasource;

  @override
  Future<List<SalaryProfile>> getSalaryProfiles(String employeeId) {
    return _datasource.getSalaryProfiles(employeeId);
  }

  @override
  Future<void> saveSalaryProfile(SalaryProfile profile) async {
    await _datasource.client.from('salary_profiles').upsert((profile as SalaryProfileModel).toJson());
  }

  @override
  Future<List<SalaryPayroll>> getPayrollHistory(String employeeId) {
    return _datasource.getPayrollHistory(employeeId);
  }

  @override
  Future<SalaryPayroll?> getPayroll(String id) {
    // TODO: implement getPayroll
    throw UnimplementedError();
  }

  @override
  Future<void> savePayroll(SalaryPayroll payroll) {
    // TODO: implement savePayroll
    throw UnimplementedError();
  }

  @override
  Future<void> markPayrollPaid(String id, SalaryPaymentMode mode, String remarks) async {
    await _datasource.markPayrollPaid(id, mode, remarks);
  }

  @override
  Future<List<SalaryAdvance>> getSalaryAdvances(String employeeId) {
    // TODO: implement getSalaryAdvances
    throw UnimplementedError();
  }

  @override
  Future<void> saveSalaryAdvance(SalaryAdvance advance) {
    // TODO: implement saveSalaryAdvance
    throw UnimplementedError();
  }

  @override
  Future<Map<String, num>> getSalaryDashboardStats() {
    return _datasource.getSalaryDashboardStats();
  }
}
