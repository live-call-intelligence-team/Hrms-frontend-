import 'package:flutter/foundation.dart';
import '../../data/models/holiday_model.dart';
import '../../data/services/holiday_service.dart';

class HolidayProvider extends ChangeNotifier {
  final HolidayService _holidayService = HolidayService();
  
  bool _isLoading = false;
  List<HolidayModel> _holidays = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<HolidayModel> get holidays => _holidays;
  String? get errorMessage => _errorMessage;

  Future<void> loadHolidays() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _holidays = await _holidayService.getHolidays();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addHoliday(HolidayModel holiday) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newHoliday = await _holidayService.addHoliday(holiday);
      _holidays.add(newHoliday);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteHoliday(int id) async {
    try {
      await _holidayService.deleteHoliday(id);
      _holidays.removeWhere((h) => h.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
