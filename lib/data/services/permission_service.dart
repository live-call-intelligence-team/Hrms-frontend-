import '../../data/models/permission_model.dart';
import 'api_service.dart';

class PermissionService {
  final ApiService _apiService = ApiService();

  Future<List<PermissionModel>> getPermissions() async {
    try {
      final response = await _apiService.get('/permissions/');
      if (response.data is List) {
        return (response.data as List)
            .map((item) => PermissionModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      // Return empty list if permissions endpoint is not ready or returns 404
       if (e.toString().contains('404')) return [];
      rethrow;
    }
  }

  Future<PermissionModel> applyPermission(PermissionModel permission) async {
    try {
      final response = await _apiService.post(
        '/permissions/',
        data: permission.toJson(),
      );
      return PermissionModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updatePermissionStatus(int id, String status) async {
    try {
      await _apiService.put(
        '/permissions/$id',
        data: {'status': status},
      );
    } catch (e) {
      rethrow;
    }
  }
}
