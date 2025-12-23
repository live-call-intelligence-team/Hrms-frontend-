import 'package:flutter/material.dart';
import '../../../data/models/job_posting_model.dart';
import '../../../data/models/candidate_model.dart';
import '../../../data/models/job_description_model.dart';
import '../../../data/services/recruitment_service.dart';

class RecruitmentProvider extends ChangeNotifier {
  final RecruitmentService _service = RecruitmentService();
  
  List<JobPostingModel> _jobPostings = [];
  List<CandidateModel> _candidates = [];
  List<JobDescriptionModel> _jobDescriptions = [];
  
  bool _isLoading = false;
  String? _error;

  List<JobPostingModel> get jobPostings => _jobPostings;
  List<CandidateModel> get candidates => _candidates;
  List<JobDescriptionModel> get jobDescriptions => _jobDescriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchJobPostings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _jobPostings = await _service.getJobPostings();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCandidates() async {
    _isLoading = true;
    notifyListeners();
    try {
      _candidates = await _service.getCandidates();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJobDescriptions() async {
     try {
       _jobDescriptions = await _service.getJobDescriptions();
       notifyListeners();
     } catch (e) {
       print('Error fetching job descriptions: $e');
     }
  }

  Future<bool> createJobPosting(Map<String, dynamic> data) async {
    try {
      final success = await _service.createJobPosting(data);
      if (success) await fetchJobPostings();
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCandidateStatus(int id, String status) async {
    try {
      final success = await _service.updateCandidateStatus(id, status);
      if (success) await fetchCandidates();
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
