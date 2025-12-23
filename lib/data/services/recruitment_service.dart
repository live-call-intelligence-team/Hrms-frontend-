import 'package:dio/dio.dart';
import '../models/job_posting_model.dart';
import '../models/candidate_model.dart';
import '../models/job_description_model.dart';
import 'api_service.dart';

class RecruitmentService {
  final ApiService _apiService = ApiService();

  // --- JOB POSTINGS ---

  Future<List<JobPostingModel>> getJobPostings() async {
    try {
      final response = await _apiService.get('/job-postings/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => JobPostingModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load job postings: $e');
    }
  }

  Future<bool> createJobPosting(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/job-postings/', data: data);
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create job posting: $e');
    }
  }

  // --- CANDIDATES ---

  Future<List<CandidateModel>> getCandidates() async {
    try {
      final response = await _apiService.get('/candidates/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CandidateModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load candidates: $e');
    }
  }

  Future<bool> updateCandidateStatus(int id, String status) async {
    try {
      final response = await _apiService.put('/candidates/$id/status/$status');
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update candidate status: $e');
    }
  }

  // --- JOB DESCRIPTIONS ---

  Future<List<JobDescriptionModel>> getJobDescriptions() async {
     try {
      final response = await _apiService.get('/job-descriptions/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => JobDescriptionModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load job descriptions: $e');
    }
  }
}
