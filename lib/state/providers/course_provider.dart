import 'package:flutter/material.dart';
import '../../data/models/course_model.dart';
import '../../data/services/course_service.dart';

class CourseProvider extends ChangeNotifier {
  final CourseService _courseService = CourseService();

  List<CourseModel> _courses = [];
  List<CourseModel> _enrolledCourses = [];
  bool _isLoading = false;
  String? _error;

  List<CourseModel> get courses => _courses;
  List<CourseModel> get enrolledCourses => _enrolledCourses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _courseService.getCourses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEnrolledCourses(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _enrolledCourses = await _courseService.getEnrollments(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CourseModel? _selectedCourse;
  CourseModel? get selectedCourse => _selectedCourse;

  Future<void> fetchCourseDetail(int id) async {
    _isLoading = true;
    _error = null;
    _selectedCourse = null; // Clear previous selection
    notifyListeners();

    try {
      _selectedCourse = await _courseService.getCourseDetail(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedCourse() {
    _selectedCourse = null;
    notifyListeners();
  }

  Future<bool> createCourse(Map<String, dynamic> data) async {
     try {
       final success = await _courseService.createCourse(data);
       if (success) await fetchCourses();
       return success;
     } catch (e) {
       _error = e.toString();
       notifyListeners();
       return false;
     }
  }

  Future<bool> updateCourse(int id, Map<String, dynamic> data) async {
     try {
       final success = await _courseService.updateCourse(id, data);
       if (success) await fetchCourses();
       return success;
     } catch (e) {
       _error = e.toString();
       notifyListeners();
       return false;
     }
  }
}
