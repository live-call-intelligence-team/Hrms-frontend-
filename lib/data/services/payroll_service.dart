import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/payroll_models.dart';

class PayrollService {
  final ApiService _apiService = ApiService();

  // --- Salary Structures ---

  Future<List<SalaryStructure>> getSalaryStructures() async {
    try {
      final response = await _apiService.get('/salary-structures/');
      if (response.data is List) {
        return (response.data as List).map((e) => SalaryStructure.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // --- Payroll ---

  Future<List<PayrollEntry>> getPayrollList({required String monthYear}) async {
    try {
      final response = await _apiService.get(
        '/payroll/',
        queryParameters: {'month': monthYear},
      );
      if (response.data is List) {
        return (response.data as List).map((e) => PayrollEntry.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      // Return empty if 404 meaning no payroll generated yet for this month
      if (e is DioException && e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<void> generatePayroll({required String monthYear}) async {
    try {
      await _apiService.post('/payroll/generate/', data: {'month': monthYear});
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> markAsPaid({required List<int> ids}) async {
      try {
          await _apiService.post('/payroll/mark-paid/', data: {'ids': ids});
      } catch (e) {
          rethrow;
      }
  }

  Future<PayrollSummary?> getPayrollSummary({required String monthYear}) async {
      try {
          final response = await _apiService.get('/payroll/summary/', queryParameters: {'month': monthYear});
          if (response.data != null) {
              return PayrollSummary.fromJson(response.data);
          }
          return null;
      } catch (e) {
          return null;
      }
  }

  // --- Payslips ---

  Future<Payslip?> getPayslip({required int payrollId}) async {
    try {
      final response = await _apiService.get('/payroll/$payrollId/payslip/');
      if (response.data != null) {
        return Payslip.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PayrollEntry>> getMyPayslips() async {
    try {
      final response = await _apiService.get('/payroll/my-history/');
       if (response.data is List) {
        return (response.data as List).map((e) => PayrollEntry.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
  
  Future<PayslipStat?> getMyPayslipStats() async {
      try {
          final response = await _apiService.get('/payroll/my-stats/');
          if (response.data != null) {
              return PayslipStat.fromJson(response.data);
          }
          return null;
      } catch (e) {
          return null;
      }
  }
}
