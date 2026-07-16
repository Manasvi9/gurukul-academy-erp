import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../students/data/models/student_summary_model.dart';
import '../../domain/entities/fee_payment_form_data.dart';
import '../models/fee_payment_model.dart';
import '../models/student_fee_ledger_model.dart';

abstract interface class FeeRemoteDataSource {
  Future<List<StudentFeeLedgerModel>> outstandingLedgers();

  Future<StudentFeeLedgerModel> studentLedger({
    required String studentId,
    required String academicYearId,
  });

  Future<List<StudentSummaryModel>> searchStudents(String query);

  Future<List<FeePaymentModel>> paymentHistory({
    required String studentId,
    required String academicYearId,
  });

  Future<String> recordPayment(FeePaymentFormData data);

  Future<void> editPayment({
    required String paymentId,
    required FeePaymentFormData data,
  });

  Future<void> voidPayment({
    required String paymentId,
    required String reason,
  });

  Future<void> markFeeComplete({
    required String studentId,
    required String academicYearId,
    required String note,
  });
}

final class SupabaseFeeRemoteDataSource implements FeeRemoteDataSource {
  SupabaseFeeRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<StudentFeeLedgerModel>> outstandingLedgers() async {
    final response = await _client
        .from('student_fee_ledger')
        .select()
        .gt('outstanding_due', 0)
        .order('student_name');
    return response
        .cast<Map<String, Object?>>()
        .map(StudentFeeLedgerModel.fromJson)
        .toList();
  }

  @override
  Future<StudentFeeLedgerModel> studentLedger({
    required String studentId,
    required String academicYearId,
  }) async {
    final response = await _client
        .from('student_fee_ledger')
        .select()
        .eq('student_id', studentId)
        .eq('academic_year_id', academicYearId)
        .single();
    return StudentFeeLedgerModel.fromJson(response);
  }

  @override
  Future<List<StudentSummaryModel>> searchStudents(String query) async {
    final response = await _client.rpc<List<dynamic>>(
      'search_students',
      params: {'search_query': query.trim()},
    );
    return response
        .cast<Map<String, Object?>>()
        .map(StudentSummaryModel.fromJson)
        .toList();
  }

  @override
  Future<List<FeePaymentModel>> paymentHistory({
    required String studentId,
    required String academicYearId,
  }) async {
    final response = await _client
        .from('student_fee_payments')
        .select()
        .eq('student_id', studentId)
        .eq('academic_year_id', academicYearId)
        .order('payment_date', ascending: false);
    return response
        .cast<Map<String, Object?>>()
        .map(FeePaymentModel.fromJson)
        .toList();
  }

  @override
  Future<String> recordPayment(FeePaymentFormData data) async {
    return _client.rpc<String>(
      'record_fee_payment',
      params: _paymentParams(data),
    );
  }

  @override
  Future<void> editPayment({
    required String paymentId,
    required FeePaymentFormData data,
  }) async {
    await _client.rpc<void>(
      'edit_fee_payment',
      params: {
        'target_payment_id': paymentId,
        ..._paymentParams(data),
      },
    );
  }

  @override
  Future<void> voidPayment({
    required String paymentId,
    required String reason,
  }) async {
    await _client.rpc<void>(
      'void_fee_payment',
      params: {'target_payment_id': paymentId, 'reason': reason},
    );
  }

  @override
  Future<void> markFeeComplete({
    required String studentId,
    required String academicYearId,
    required String note,
  }) async {
    await _client.rpc<void>(
      'mark_fee_complete',
      params: {
        'target_student_id': studentId,
        'target_academic_year_id': academicYearId,
        'note': note,
      },
    );
  }

  Map<String, Object?> _paymentParams(FeePaymentFormData data) {
    return {
      'target_student_id': data.studentId,
      'target_academic_year_id': data.academicYearId,
      'amount': data.amount,
      'payment_date': _dateOnly(data.paymentDate),
      'payment_mode': data.paymentMode,
      'reference_number': data.referenceNumber,
      'note': data.note,
    };
  }

  String _dateOnly(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
