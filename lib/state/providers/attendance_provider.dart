import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../data/models/attendance_model.dart';
import '../../data/services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  
  bool _isLoading = false;
  AttendanceModel? _todayAttendance;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  AttendanceModel? get todayAttendance => _todayAttendance;
  String? get errorMessage => _errorMessage;

  /// Load today's attendance data
  Future<void> loadTodayAttendance() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todayAttendance = await _attendanceService.getTodayAttendance();
    } catch (e) {
      if (e is DioException) {
        _errorMessage = e.message; // Or simplified error message
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<AttendanceModel> _history = [];
  List<AttendanceModel> get history => _history;

  Future<void> getAttendanceHistory(DateTime start, DateTime end) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _history = await _attendanceService.getAttendanceHistory(
        startDate: start,
        endDate: end,
      );
    } catch (e) {
      if (e is DioException) {
         _errorMessage = e.message;
      } else {
         _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Punch In/Out
  Future<bool> punch(String type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todayAttendance = await _attendanceService.punch(type);
      return true;
    } catch (e) {
      if (e is DioException) {
        // Handle specific error like 400 for already punched
        if (e.response?.data != null && e.response!.data is Map) {
          _errorMessage = e.response!.data['detail'] ?? 'Failed to punch $type';
        } else {
          _errorMessage = e.message;
        }
      } else {
        _errorMessage = e.toString();
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
