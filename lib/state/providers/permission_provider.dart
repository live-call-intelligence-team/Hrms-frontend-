import 'package:flutter/foundation.dart';
import '../../data/models/permission_model.dart';
import '../../data/services/permission_service.dart';

class PermissionProvider extends ChangeNotifier {
  final PermissionService _permissionService = PermissionService();
  
  bool _isLoading = false;
  List<PermissionModel> _permissions = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<PermissionModel> get permissions => _permissions;
  String? get errorMessage => _errorMessage;

  Future<void> loadPermissions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _permissions = await _permissionService.getPermissions();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyPermission(PermissionModel permission) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPerm = await _permissionService.applyPermission(permission);
      _permissions.add(newPerm);
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
      await _permissionService.updatePermissionStatus(id, status);
      await loadPermissions();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
