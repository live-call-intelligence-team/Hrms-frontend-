import 'package:flutter/foundation.dart';
import '../../data/models/leave_model.dart';
import '../../data/services/leave_service.dart';

class LeaveProvider extends ChangeNotifier {
  final LeaveService _leaveService = LeaveService();
  
  bool _isLoading = false;
  List<LeaveModel> _leaveRequests = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<LeaveModel> get leaveRequests => _leaveRequests;
  String? get errorMessage => _errorMessage;

  Future<void> loadLeaveRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _leaveRequests = await _leaveService.getLeaveRequests();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyLeave(LeaveModel leave) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newLeave = await _leaveService.applyLeave(leave);
      _leaveRequests.add(newLeave);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(int id, String status) async {
    try {
      await _leaveService.updateLeaveStatus(id, status);
      final index = _leaveRequests.indexWhere((l) => l.id == id);
      if (index != -1) {
         // Create new object with updated status for reactivity
         // In a real app we might reload the list or use copyWith
         // For now, reload
         await loadLeaveRequests();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
