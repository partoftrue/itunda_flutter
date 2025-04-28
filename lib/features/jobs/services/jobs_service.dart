import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/auth_service.dart';
import '../models/job.dart';
import '../models/job_category.dart';
import '../../../core/config/api_config.dart';
import 'jobs_api_client.dart';

class JobsService extends ChangeNotifier {
  final JobsApiClient _apiClient;
  
  final String _baseUrl = ApiConfig.baseUrl;
  
  List<Job> _jobs = [];
  List<Job> _bookmarkedJobs = [];
  List<JobCategory> _categories = [];
  Job? _selectedJob;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreJobs = true;
  String _selectedCategory = '';
  String _selectedLocation = '';

  JobsService({
    required http.Client httpClient,
    
  }) : _apiClient = JobsApiClient(
         httpClient: httpClient,
         
       

  // Getters
  List<Job> get jobs => _jobs;
  List<Job> get bookmarkedJobs => _bookmarkedJobs;
  List<JobCategory> get categories => _categories;
  Job? get selectedJob => _selectedJob;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreJobs => _hasMoreJobs;
  String get selectedCategory => _selectedCategory;
  String get selectedLocation => _selectedLocation;

  // Initialize the service
  Future<void> init() async {
    await Future.wait([
      fetchJobs(),
      fetchCategories(),
    ]);
  }

  // Fetch jobs with optional filtering
  Future<void> fetchJobs({
    String? query,
    String? categoryId,
    String? location,
    double? minSalary,
    double? maxSalary,
    String? jobType,
    String? sortBy,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) queryParams['query'] = query;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (location != null) queryParams['location'] = location;
      if (minSalary != null) queryParams['minSalary'] = minSalary.toString();
      if (maxSalary != null) queryParams['maxSalary'] = maxSalary.toString();
      if (jobType != null) queryParams['jobType'] = jobType;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      
      final uri = Uri.parse('$_baseUrl/jobs').replace(queryParameters: queryParams);
      // Auth removed: no token required
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _jobs = (data['jobs'] as List)
            .map((job) => Job.fromJson(job))
            .toList();
      } else {
        _errorMessage = 'Failed to load jobs: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load jobs: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Get a specific job by ID
  Future<void> fetchJobById(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      _selectedJob = await _apiClient.getJobById(id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch job details: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch bookmarked jobs
  Future<void> fetchBookmarkedJobs() async {
    _setLoading(true);
    _clearError();
    
    try {
      _bookmarkedJobs = await _apiClient.getBookmarkedJobs();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch bookmarked jobs: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle bookmark status for a job
  Future<void> toggleBookmark(String jobId) async {
    _clearError();
    
    try {
      // Find job in the list
      final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
      if (jobIndex >= 0) {
        final job = _jobs[jobIndex];
        final newStatus = await _apiClient.toggleBookmark(jobId, job.isBookmarked);
        
        // Update job in list
        _jobs[jobIndex] = job.copyWith(isBookmarked: newStatus);
        
        // If selected job is affected, update it too
        if (_selectedJob?.id == jobId) {
          _selectedJob = _selectedJob!.copyWith(isBookmarked: newStatus);
        }
        
        // Update bookmark list if necessary
        if (newStatus) {
          if (!_bookmarkedJobs.any((j) => j.id == jobId)) {
            _bookmarkedJobs.add(_jobs[jobIndex]);
          }
        } else {
          _bookmarkedJobs.removeWhere((j) => j.id == jobId);
        }
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update bookmark: ${e.toString()}');
    }
  }

  // Load job categories
  Future<void> fetchCategories() async {
    _setLoading(true);
    _clearError();
    
    try {
      _categories = await _apiClient.getJobCategories();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch job categories: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new job listing
  Future<Job?> createJob({
    required String title,
    required String company,
    required String location,
    required String description,
    required String salary,
    required String jobType,
    required String category,
    String? contactEmail,
    String? contactPhone,
    List<String>? requirements,
    List<String>? benefits,
    List<File>? images,
    File? companyLogo,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final job = await _apiClient.createJob(
        title: title,
        company: company,
        location: location,
        description: description,
        salary: salary,
        jobType: jobType,
        category: category,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        requirements: requirements,
        benefits: benefits,
        images: images,
        companyLogo: companyLogo,
      );
      
      // Add to jobs list
      _jobs.insert(0, job);
      notifyListeners();
      
      return job;
    } catch (e) {
      _setError('Failed to create job: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Apply for a job
  Future<bool> applyForJob({
    required String jobId,
    required String coverLetter,
    File? resume,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiClient.applyForJob(
        jobId: jobId,
        coverLetter: coverLetter,
        resume: resume,
      );
      
      // Update applicant count if this is the selected job
      if (_selectedJob?.id == jobId) {
        final currentCount = _selectedJob?.applicantCount ?? 0;
        _selectedJob = _selectedJob!.copyWith(
          applicantCount: currentCount + 1,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Failed to apply for job: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search for jobs
  Future<void> searchJobs(String query) async {
    _setLoading(true);
    _clearError();
    
    try {
      _jobs = await _apiClient.searchJobs(query);
      notifyListeners();
    } catch (e) {
      _setError('Failed to search jobs: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }

  // Load jobs with optional filtering
  Future<void> loadJobs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreJobs = true;
    }

    if (!_hasMoreJobs && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final jobs = await _apiClient.getJobs(
        category: _selectedCategory,
        location: _selectedLocation,
        page: _currentPage,
      );

      if (refresh) {
        _jobs = jobs;
      } else {
        _jobs.addAll(jobs);
      }

      _hasMoreJobs = jobs.isNotEmpty;
      if (_hasMoreJobs) _currentPage++;
    } catch (e) {
      _errorMessage = 'Failed to load jobs: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more jobs when scrolling
  Future<void> loadMoreJobs() async {
    if (!_isLoading && _hasMoreJobs) {
      await loadJobs();
    }
  }

  // Filter jobs by category
  Future<void> filterByCategory(String category) async {
    if (_selectedCategory == category) return;
    
    _selectedCategory = category;
    await loadJobs(refresh: true);
  }

  // Filter jobs by location
  Future<void> filterByLocation(String location) async {
    if (_selectedLocation == location) return;
    
    _selectedLocation = location;
    await loadJobs(refresh: true);
  }

  // Get job details by ID
  Future<void> getJobDetails(String jobId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final job = await _apiClient.getJobById(jobId);
      _selectedJob = job;
    } catch (e) {
      _errorMessage = 'Failed to load job details: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load bookmarked jobs
  Future<void> loadBookmarkedJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookmarkedJobs = await _apiClient.getBookmarkedJobs();
    } catch (e) {
      _errorMessage = 'Failed to load bookmarked jobs: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset all filters
  void resetFilters() {
    _selectedCategory = '';
    _selectedLocation = '';
    loadJobs(refresh: true);
  }
} 