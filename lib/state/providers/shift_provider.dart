import 'package:flutter/foundation.dart';
import 'package:hrms_frontend/data/models/shift_models.dart';
import 'package:hrms_frontend/data/services/shift_service.dart';

class ShiftProvider with ChangeNotifier {
  final ShiftService _shiftService = ShiftService();

  List<Shift> _shifts = [];
  List<ShiftRoster> _rosters = [];
  List<UserShift> _userShifts = [];
  List<ShiftChangeRequest> _changeRequests = [];
  ShiftSummary? _summary;

  bool _isLoading = false;
  String? _errorMessage;

  List<Shift> get shifts => _shifts;
  List<ShiftRoster> get rosters => _rosters;
  List<UserShift> get userShifts => _userShifts;
  List<ShiftChangeRequest> get changeRequests => _changeRequests;
  ShiftSummary? get summary => _summary;
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

  Future<void> loadShifts() async {
    _setLoading(true);
    _setError(null);
    try {
      _shifts = await _shiftService.getShifts();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createShift(Shift shift) async {
    _setLoading(true);
    _setError(null);
    try {
      await _shiftService.createShift(shift.toJson());
      await loadShifts();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateShift(int id, Shift shift) async {
    _setLoading(true);
    _setError(null);
    try {
      await _shiftService.updateShift(id, shift.toJson());
      await loadShifts();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteShift(int id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _shiftService.deleteShift(id);
      await loadShifts();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRosters() async {
    _setLoading(true);
    try {
      _rosters = await _shiftService.getRosters();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserShifts() async {
    _setLoading(true);
    try {
      _userShifts = await _shiftService.getUserShifts();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadChangeRequests() async {
    _setLoading(true);
    try {
      _changeRequests = await _shiftService.getShiftChangeRequests();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> requestShiftChange(ShiftChangeRequest request) async {
    _setLoading(true);
    try {
      await _shiftService.requestShiftChange(request.toJson());
      await loadChangeRequests();
       return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
    Future<bool> updateChangeRequestStatus(int id, String status) async {
    _setLoading(true);
    try {
      await _shiftService.updateShiftChangeRequestStatus(id, status);
      await loadChangeRequests();
       return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }


  Future<void> loadSummary() async {
    _setLoading(true);
    try {
      _summary = await _shiftService.getShiftSummary();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
