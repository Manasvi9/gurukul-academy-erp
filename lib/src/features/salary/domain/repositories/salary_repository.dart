import '../entities/salary_entities.dart';
import '../entities/salary_payment_enums.dart';

abstract interface class SalaryRepository {
  // Salary Profiles
  Future<List<SalaryProfile>> getSalaryProfiles(String employeeId);
  Future<void> saveSalaryProfile(SalaryProfile profile);

  // Payroll
  Future<List<SalaryPayroll>> getPayrollHistory(String employeeId);
  Future<SalaryPayroll?> getPayroll(String id);
  Future<void> savePayroll(SalaryPayroll payroll);
  Future<void> markPayrollPaid(String id, SalaryPaymentMode mode, String remarks);

  // Advances
  Future<List<SalaryAdvance>> getSalaryAdvances(String employeeId);
  Future<void> saveSalaryAdvance(SalaryAdvance advance);

  // Dashboard Stats
  Future<Map<String, num>> getSalaryDashboardStats();
}
