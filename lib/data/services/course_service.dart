import 'package:dio/dio.dart';
import '../models/course_model.dart';
import '../../core/config/app_config.dart';
import 'api_service.dart';

class CourseService {
  final ApiService _apiService = ApiService();

  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await _apiService.get('/courses/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CourseModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  Future<bool> createCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await _apiService.post(
        '/courses/',
        data: courseData,
      );
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create course: $e');
    }
  }
  
  Future<bool> updateCourse(int id, Map<String, dynamic> courseData) async {
    try {
      final response = await _apiService.put(
        '/courses/$id',
        data: courseData,
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }

  Future<List<CourseModel>> getEnrollments(int userId) async {
    try {
      final response = await _apiService.get('/enrollments/user/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
           if (json['course'] != null) {
             return CourseModel.fromJson(json['course']);
           }
           // Should ideally not happen if backend is correct
           return CourseModel.fromJson(json);
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load enrolled courses: $e');
    }
  }

  Future<CourseModel?> getCourseDetail(int id) async {
    try {
      final response = await _apiService.get('/courses/$id');
      if (response.statusCode == 200) {
        return CourseModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load course details: $e');
    }
  }
}
