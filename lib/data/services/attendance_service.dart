import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/attendance_model.dart';
import 'package:intl/intl.dart';

class AttendanceService {
  final ApiService _apiService = ApiService();

  /// Get today's attendance for the current user
  Future<AttendanceModel?> getTodayAttendance() async {
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      
      // Assuming the backend has an endpoint to get attendance by date or 'today'
      // If not, we might need to filter from a list. 
      // Based on requirements: GET /attendance/ (today)
      final response = await _apiService.get('/attendance/today'); 
      
      if (response.data != null) {
        return AttendanceModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      // If 404, it might mean no record exists yet for today, which is fine
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Punch In or Out
  /// type: 'in' or 'out'
  Future<AttendanceModel> punch(String type) async {
    try {
      final response = await _apiService.post(
        '/attendance-punch/',
        data: {'type': type},
      );
      
      return AttendanceModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get attendance history for a specific month/range
  Future<List<AttendanceModel>> getAttendanceHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);
      
      final response = await _apiService.get(
        '/attendance/',
        queryParameters: {
          'start_date': startStr,
          'end_date': endStr,
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((item) => AttendanceModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
