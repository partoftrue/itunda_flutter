import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/config.dart';
import '../../../core/services/auth_service.dart';
import '../models/job.dart';
import '../../../core/constants/api.dart';

class JobsApiClient {
  
  final http.Client _httpClient;
  final String _baseUrl;

  JobsApiClient({
    
    http.Client? httpClient,
  })  : 
        _httpClient = httpClient ?? http.Client(),
        _baseUrl = AppConfig.apiUrl;

  /// Get all jobs with optional filtering
  Future<List<Job>> getJobs({
    String? category,
    double? minSalary,
    double? maxSalary,
    String? sortBy,
    String? sortDirection,
    int? page,
    int? limit,
    String? query,
  }) async {
    final queryParams = <String, String>{};
    
    if (category != null) queryParams['category'] = category;
    if (minSalary != null) queryParams['minSalary'] = minSalary.toString();
    if (maxSalary != null) queryParams['maxSalary'] = maxSalary.toString();
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortDirection != null) queryParams['sortDirection'] = sortDirection;
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (query != null && query.isNotEmpty) queryParams['query'] = query;

    final url = Uri.parse('${ApiConstants.baseUrl}/jobs').replace(
      queryParameters: queryParams,
    );

    final response = await _httpClient.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['jobs'] as List)
          .map((job) => Job.fromJson(job))
          .toList();
    } else {
      throw Exception('Failed to load jobs: ${response.body}');
    }
  }

  /// Get a job by ID
  Future<Job> getJobById(String id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs/$id');
    
    final response = await _httpClient.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Job.fromJson(data);
    } else {
      throw Exception('Failed to load job: ${response.body}');
    }
  }

  /// Get bookmarked jobs for the current user
  Future<List<Job>> getBookmarkedJobs() async {
    // Auth removed: no token required
    
    if (token == null) {
      throw Exception('Authentication required');
    }
    
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs/bookmarked');
    
    final response = await _httpClient.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['jobs'] as List)
          .map((job) => Job.fromJson(job))
          .toList();
    } else {
      throw Exception('Failed to load bookmarked jobs: ${response.body}');
    }
  }

  /// Toggle bookmark status for a job
  Future<bool> toggleBookmark(String jobId, bool currentStatus) async {
    // Auth removed: no token required
    
    if (token == null) {
      throw Exception('Authentication required');
    }
    
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs/$jobId/bookmark');
    
    final response = currentStatus
        ? await _httpClient.delete(
            url,
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
        : await _httpClient.post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
            },
          );
    
    if (response.statusCode == 200) {
      return !currentStatus;
    } else {
      throw Exception('Failed to toggle bookmark: ${response.body}');
    }
  }

  /// Get job categories
  Future<List<String>> getJobCategories() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs/categories');
    
    final response = await _httpClient.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['categories'] as List)
          .map((category) => category as String)
          .toList();
    } else {
      throw Exception('Failed to load job categories: ${response.body}');
    }
  }

  /// Create a new job listing
  Future<Job> createJob({
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
    // Auth removed: no token required
    
    if (token == null) {
      throw Exception('Authentication required');
    }
    
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs');
    
    var request = http.MultipartRequest('POST', url);
    
    request.headers['Authorization'] = 'Bearer $token';
    
    // Add text fields
    request.fields['title'] = title;
    request.fields['company'] = company;
    request.fields['location'] = location;
    request.fields['description'] = description;
    request.fields['salary'] = salary;
    request.fields['jobType'] = jobType;
    request.fields['category'] = category;
    
    if (contactEmail != null) request.fields['contactEmail'] = contactEmail;
    if (contactPhone != null) request.fields['contactPhone'] = contactPhone;
    if (requirements != null) request.fields['requirements'] = json.encode(requirements);
    if (benefits != null) request.fields['benefits'] = json.encode(benefits);
    
    // Add company logo if provided
    if (companyLogo != null) {
      final companyLogoStream = http.ByteStream(companyLogo.openRead());
      final companyLogoLength = await companyLogo.length();
      final companyLogoMultipart = http.MultipartFile(
        'companyLogo',
        companyLogoStream,
        companyLogoLength,
        filename: companyLogo.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      
      request.files.add(companyLogoMultipart);
    }
    
    // Add images if provided
    if (images != null && images.isNotEmpty) {
      for (var i = 0; i < images.length; i++) {
        final image = images[i];
        final imageStream = http.ByteStream(image.openRead());
        final imageLength = await image.length();
        final imageMultipart = http.MultipartFile(
          'images',
          imageStream,
          imageLength,
          filename: image.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        
        request.files.add(imageMultipart);
      }
    }
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Job.fromJson(data);
    } else {
      throw Exception('Failed to create job: ${response.body}');
    }
  }

  /// Apply for a job
  Future<void> applyForJob({
    required String jobId,
    required String coverLetter,
    File? resume,
  }) async {
    // Auth removed: no token required
    
    if (token == null) {
      throw Exception('Authentication required');
    }
    
    final url = Uri.parse('${ApiConstants.baseUrl}/jobs/$jobId/apply');
    
    var request = http.MultipartRequest('POST', url);
    
    request.headers['Authorization'] = 'Bearer $token';
    
    // Add cover letter
    request.fields['coverLetter'] = coverLetter;
    
    // Add resume if provided
    if (resume != null) {
      final resumeStream = http.ByteStream(resume.openRead());
      final resumeLength = await resume.length();
      final resumeMultipart = http.MultipartFile(
        'resume',
        resumeStream,
        resumeLength,
        filename: resume.path.split('/').last,
        contentType: MediaType('application', 'pdf'),
      );
      
      request.files.add(resumeMultipart);
    }
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to apply for job: ${response.body}');
    }
  }

  /// Search for jobs
  Future<List<Job>> searchJobs(String query) async {
    return getJobs(query: query);
  }
} 