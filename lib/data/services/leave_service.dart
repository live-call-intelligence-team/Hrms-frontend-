import 'package:dio/dio.dart';
import '../../data/models/leave_model.dart';
import 'api_service.dart';

class LeaveService {
  final ApiService _apiService = ApiService();

  Future<List<LeaveModel>> getLeaveRequests() async {
    try {
      final response = await _apiService.get('/leavemaster/');
      if (response.data is List) {
        return (response.data as List)
            .map((item) => LeaveModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<LeaveModel> applyLeave(LeaveModel leave) async {
    try {
      final response = await _apiService.post(
        '/leavemaster/',
        data: leave.toJson(),
      );
      return LeaveModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateLeaveStatus(int id, String status) async {
    try {
      await _apiService.put(
        '/leavemaster/$id',
        data: {'status': status},
      );
    } catch (e) {
      rethrow;
    }
  }
}
