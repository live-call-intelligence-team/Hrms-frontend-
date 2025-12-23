import 'package:dio/dio.dart';
import '../models/category_model.dart';
import 'api_service.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get('/categories/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<bool> createCategory(String name) async {
    try {
      final response = await _apiService.post(
        '/categories/',
        data: {'name': name},
      );
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<bool> updateCategory(int id, String name) async {
    try {
      final response = await _apiService.put(
        '/categories/$id',
        data: {'name': name},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final response = await _apiService.delete('/categories/$id');
      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
