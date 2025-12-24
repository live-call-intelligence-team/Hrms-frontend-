import '../../data/models/holiday_model.dart';
import 'api_service.dart';

class HolidayService {
  final ApiService _apiService = ApiService();

  Future<List<HolidayModel>> getHolidays() async {
    try {
      final response = await _apiService.get('/holidays/');
      if (response.data is List) {
        return (response.data as List)
            .map((item) => HolidayModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
       if (e.toString().contains('404')) return [];
      rethrow;
    }
  }

  Future<HolidayModel> addHoliday(HolidayModel holiday) async {
    try {
      final response = await _apiService.post(
        '/holidays/',
        data: holiday.toJson(),
      );
      return HolidayModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteHoliday(int id) async {
    try {
      await _apiService.delete('/holidays/$id');
    } catch (e) {
      rethrow;
    }
  }
}
