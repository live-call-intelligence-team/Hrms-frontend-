import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/shift_models.dart';

class ShiftService {
  final ApiService _apiService = ApiService();

  // --- Shifts ---

  Future<List<Shift>> getShifts() async {
    try {
      final response = await _apiService.get('/shifts/');
      if (response.data is List) {
        return (response.data as List).map((e) => Shift.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createShift(Map<String, dynamic> data) async {
    try {
      await _apiService.post('/shifts/', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateShift(int id, Map<String, dynamic> data) async {
    try {
      await _apiService.put('/shifts/$id/', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteShift(int id) async {
    try {
      await _apiService.delete('/shifts/$id/');
    } catch (e) {
      rethrow;
    }
  }

  // --- Rosters ---

  Future<List<ShiftRoster>> getRosters() async {
    try {
      final response = await _apiService.get('/shift-rosters/');
      if (response.data is List) {
        return (response.data as List).map((e) => ShiftRoster.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Placeholder for creating/managing rosters
  // Future<void> createRoster(...) async { ... }

  // --- User Shifts ---

  Future<List<UserShift>> getUserShifts() async {
    try {
      final response = await _apiService.get('/user-shifts/');
      if (response.data is List) {
        return (response.data as List).map((e) => UserShift.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // --- Shift Change Requests ---

  Future<List<ShiftChangeRequest>> getShiftChangeRequests() async {
    try {
       // Assuming this endpoint returns list of requests. 
       // Might need different endpoints for "My Requests" vs "Pending Requests (Manager)"
       // Using generic GET for now.
      final response = await _apiService.get('/shift-change-requests/');
      if (response.data is List) {
        return (response.data as List).map((e) => ShiftChangeRequest.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestShiftChange(Map<String, dynamic> data) async {
    try {
      await _apiService.post('/shift-change-requests/', data: data);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateShiftChangeRequestStatus(int id, String status) async {
      try {
          await _apiService.put('/shift-change-requests/$id/', data: {'status': status});
      } catch (e) {
          rethrow;
      }
  }


  // --- Summary ---

  Future<ShiftSummary?> getShiftSummary() async {
    try {
      final response = await _apiService.get('/shift-summary/');
      if (response.data != null) {
        return ShiftSummary.fromJson(response.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
