import 'package:flutter/foundation.dart';
import 'package:hrms_frontend/data/models/payroll_models.dart';
import 'package:hrms_frontend/data/services/payroll_service.dart';

class PayrollProvider with ChangeNotifier {
  final PayrollService _payrollService = PayrollService();

  List<SalaryStructure> _structures = [];
  List<PayrollEntry> _payrollList = [];
  List<PayrollEntry> _myPayslipHistory = [];
  Payslip? _currentPayslip;
  PayrollSummary? _payrollSummary;
  PayslipStat? _myStats;

  bool _isLoading = false;
  String? _errorMessage;

  List<SalaryStructure> get structures => _structures;
  List<PayrollEntry> get payrollList => _payrollList;
  List<PayrollEntry> get myPayslipHistory => _myPayslipHistory;
  Payslip? get currentPayslip => _currentPayslip;
  PayrollSummary? get payrollSummary => _payrollSummary;
  PayslipStat? get myStats => _myStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> loadSalaryStructures() async {
    _setLoading(true);
    try {
      _structures = await _payrollService.getSalaryStructures();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPayrollList(String monthYear) async {
    _setLoading(true);
    try {
      _payrollList = await _payrollService.getPayrollList(monthYear: monthYear);
      await loadPayrollSummary(monthYear);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> generatePayroll(String monthYear) async {
    _setLoading(true);
    try {
      await _payrollService.generatePayroll(monthYear: monthYear);
      await loadPayrollList(monthYear);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> markAsPaid(List<int> ids, String currentMonthYear) async {
       _setLoading(true);
        try {
          await _payrollService.markAsPaid(ids: ids);
          await loadPayrollList(currentMonthYear);
          return true;
        } catch (e) {
          _setError(e.toString());
          return false;
        } finally {
          _setLoading(false);
        }
  }

  Future<void> loadPayrollSummary(String monthYear) async {
      try {
          _payrollSummary = await _payrollService.getPayrollSummary(monthYear: monthYear);
      } catch (e) {
          // ignore error for summary
      }
  }

  Future<void> loadPayslip(int payrollId) async {
    _setLoading(true);
    try {
      _currentPayslip = await _payrollService.getPayslip(payrollId: payrollId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  void clearCurrentPayslip() {
      _currentPayslip = null;
  }

  Future<void> loadMyPayslips() async {
    _setLoading(true);
    try {
      _myPayslipHistory = await _payrollService.getMyPayslips();
      await loadMyStats();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> loadMyStats() async {
      try {
          _myStats = await _payrollService.getMyPayslipStats();
      } catch (e) {
          // ignore
      }
  }
}


