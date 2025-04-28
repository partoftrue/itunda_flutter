import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/job.dart';
import '../models/job_category.dart';
import '/core/config/config.dart';
import '/core/services/auth_service.dart';

class JobService extends ChangeNotifier {
  
  final String _baseUrl = Config.apiUrl;
  
  List<Job> _jobs = [];
  List<Job> _bookmarkedJobs = [];
  List<Job> _appliedJobs = [];
  List<JobCategory> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  JobService() {
    _initialize();
  }

  List<Job> get jobs => _jobs;
  List<Job> get bookmarkedJobs => _bookmarkedJobs;
  List<Job> get appliedJobs => _appliedJobs;
  List<JobCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _initialize() async {
    await Future.wait([
      getCategories(),
      getJobs(),
      getBookmarkedJobs(),
      getAppliedJobs(),
    ]);
  }

  Future<void> getJobs({String? categoryId, String? query}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (query != null && query.isNotEmpty) queryParams['query'] = query;

      final uri = Uri.parse('${_baseUrl}/jobs').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _jobs = data.map((item) => Job.fromJson(item)).toList();
      } else {
        _errorMessage = 'Failed to fetch jobs: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching jobs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // This would typically be an API call, but for this example,
      // we'll use the default categories
      _categories = JobCategory.getDefaultCategories();
    } catch (e) {
      _errorMessage = 'Error fetching job categories: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getBookmarkedJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Auth removed: always allow
        _bookmarkedJobs = [];
        return;
      }

      final response = await http.get(
        Uri.parse('${_baseUrl}/jobs/bookmarked'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _bookmarkedJobs = data.map((item) => Job.fromJson(item)).toList();
      } else {
        _errorMessage = 'Failed to fetch bookmarked jobs: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching bookmarked jobs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAppliedJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Auth removed: always allow
        _appliedJobs = [];
        return;
      }

      final response = await http.get(
        Uri.parse('${_baseUrl}/jobs/applied'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _appliedJobs = data.map((item) => Job.fromJson(item)).toList();
      } else {
        _errorMessage = 'Failed to fetch applied jobs: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching applied jobs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleBookmark(String jobId) async {
    try {
      // Auth removed: always allow
        return false;
      }

      final response = await http.post(
        Uri.parse('${_baseUrl}/jobs/$jobId/bookmark'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        // Update local jobs list
        final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
        if (jobIndex != -1) {
          final job = _jobs[jobIndex];
          final updatedJob = job.copyWith(isBookmarked: !job.isBookmarked);
          _jobs[jobIndex] = updatedJob;
        }
        
        // Update bookmarked jobs list
        await getBookmarkedJobs();
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to bookmark job: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error bookmarking job: $e';
      return false;
    }
  }

  Future<bool> applyForJob(String jobId) async {
    try {
      // Auth removed: always allow
        return false;
      }

      final response = await http.post(
        Uri.parse('${_baseUrl}/jobs/$jobId/apply'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        // Update local jobs list
        final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
        if (jobIndex != -1) {
          final job = _jobs[jobIndex];
          final updatedJob = job.copyWith(isApplied: true);
          _jobs[jobIndex] = updatedJob;
        }
        
        // Update applied jobs list
        await getAppliedJobs();
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to apply for job: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error applying for job: $e';
      return false;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_authService.isLoggedIn) {
      // Auth removed: no Authorization header
    }

    return headers;
  }

  // Simulate job data when running in demo mode
  Future<void> loadDemoData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _categories = JobCategory.getDefaultCategories();
      
      // Create sample jobs
      final demoJobs = _createDemoJobs();
      _jobs = demoJobs;
      
      // Mark some as bookmarked
      _bookmarkedJobs = demoJobs.where((job) => job.isBookmarked).toList();
      
      // Mark some as applied
      _appliedJobs = demoJobs.where((job) => job.isApplied).toList();
    } catch (e) {
      _errorMessage = 'Error loading demo data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Job> _createDemoJobs() {
    final now = DateTime.now();
    final categories = JobCategory.getDefaultCategories();
    
    return [
      Job(
        id: '1',
        title: 'Senior Flutter Developer',
        companyName: 'Tech Innovations',
        companyLogo: 'https://randomuser.me/api/portraits/men/1.jpg',
        location: 'Seoul, South Korea',
        salary: '₩80,000,000 - ₩100,000,000',
        isSalaryNegotiable: false,
        jobType: 'Full-time',
        category: categories[0],
        description: 'We are looking for an experienced Flutter developer who can lead our mobile app development team.',
        requirements: [
          'Minimum 5 years of experience with Flutter',
          'Strong knowledge of Dart programming language',
          'Experience with state management solutions',
          'Ability to write clean, maintainable code'
        ],
        responsibilities: [
          'Lead a team of mobile developers',
          'Design and implement new features',
          'Troubleshoot and fix bugs',
          'Collaborate with the product team'
        ],
        benefits: [
          'Competitive salary',
          'Health insurance',
          'Flexible working hours',
          'Remote work options'
        ],
        postedDate: now.subtract(const Duration(days: 2)),
        applicationDeadline: now.add(const Duration(days: 28)),
        isBookmarked: true,
        isApplied: false,
        contactEmail: 'jobs@techinnovations.com',
        contactPhone: '+82 10 1234 5678',
        websiteUrl: 'https://techinnovations.com',
      ),
      Job(
        id: '2',
        title: 'UX/UI Designer',
        companyName: 'Creative Solutions',
        companyLogo: 'https://randomuser.me/api/portraits/women/2.jpg',
        location: 'Busan, South Korea',
        salary: '₩60,000,000 - ₩75,000,000',
        isSalaryNegotiable: true,
        jobType: 'Full-time',
        category: categories[5],
        description: 'Join our creative team as a UX/UI Designer to create beautiful and functional user interfaces.',
        requirements: [
          'Degree in Design, Fine Arts, or related field',
          'Proficiency in Figma, Sketch, and Adobe Creative Suite',
          'Portfolio demonstrating UI/UX skills',
          'Understanding of user research and testing methodologies'
        ],
        responsibilities: [
          'Create wireframes, prototypes, and high-fidelity designs',
          'Conduct user research and testing',
          'Collaborate with developers to implement designs',
          'Stay updated with the latest design trends'
        ],
        benefits: [
          'Creative work environment',
          'Professional development budget',
          'Flexible schedule',
          'Free snacks and coffee'
        ],
        postedDate: now.subtract(const Duration(days: 5)),
        applicationDeadline: now.add(const Duration(days: 25)),
        isBookmarked: false,
        isApplied: true,
        contactEmail: 'careers@creativesolutions.com',
        contactPhone: '+82 10 9876 5432',
        websiteUrl: 'https://creativesolutions.com',
      ),
      Job(
        id: '3',
        title: 'Data Scientist',
        companyName: 'Data Insights',
        companyLogo: 'https://randomuser.me/api/portraits/women/3.jpg',
        location: 'Seoul, South Korea',
        salary: '₩70,000,000 - ₩90,000,000',
        isSalaryNegotiable: false,
        jobType: 'Full-time',
        category: categories[0],
        description: 'Looking for a data scientist to help us extract insights from our vast data sets.',
        requirements: [
          'Advanced degree in Statistics, Mathematics, Computer Science, or related field',
          'Experience with Python, R, SQL, and data visualization tools',
          'Knowledge of machine learning algorithms',
          'Strong analytical and problem-solving skills'
        ],
        responsibilities: [
          'Develop and implement data models',
          'Extract insights from complex datasets',
          'Create visualizations and reports',
          'Collaborate with product and engineering teams'
        ],
        benefits: [
          'Competitive compensation',
          'Health and wellness programs',
          'Continued education support',
          'Opportunity to work on cutting-edge projects'
        ],
        postedDate: now.subtract(const Duration(days: 7)),
        applicationDeadline: now.add(const Duration(days: 23)),
        isBookmarked: true,
        isApplied: true,
        contactEmail: 'careers@datainsights.com',
        contactPhone: '+82 10 2468 1357',
        websiteUrl: 'https://datainsights.com',
      ),
      Job(
        id: '4',
        title: 'Frontend Developer',
        companyName: 'Web Wizards',
        companyLogo: 'https://randomuser.me/api/portraits/men/4.jpg',
        location: 'Incheon, South Korea',
        salary: '₩55,000,000 - ₩70,000,000',
        isSalaryNegotiable: false,
        jobType: 'Full-time',
        category: categories[0],
        description: 'Join our team to build beautiful and responsive web applications.',
        requirements: [
          'Strong knowledge of HTML, CSS, and JavaScript',
          'Experience with React, Vue, or Angular',
          'Understanding of responsive design principles',
          'Familiarity with version control systems'
        ],
        responsibilities: [
          'Develop user interfaces using modern frameworks',
          'Ensure cross-browser compatibility',
          'Optimize applications for maximum speed',
          'Collaborate with backend developers'
        ],
        benefits: [
          'Competitive salary',
          'Remote work options',
          'Professional growth opportunities',
          'Modern office environment'
        ],
        postedDate: now.subtract(const Duration(days: 10)),
        applicationDeadline: now.add(const Duration(days: 20)),
        isBookmarked: false,
        isApplied: false,
        contactEmail: 'jobs@webwizards.com',
        contactPhone: '+82 10 1357 2468',
        websiteUrl: 'https://webwizards.com',
      ),
      Job(
        id: '5',
        title: 'Product Manager',
        companyName: 'Innovative Products',
        companyLogo: 'https://randomuser.me/api/portraits/women/5.jpg',
        location: 'Seoul, South Korea',
        salary: '₩85,000,000 - ₩110,000,000',
        isSalaryNegotiable: true,
        jobType: 'Full-time',
        category: categories[0],
        description: 'Lead the development of innovative products from conception to launch.',
        requirements: [
          'Bachelor's degree in Business, Computer Science, or related field',
          'Minimum 3 years of experience in product management',
          'Strong analytical and problem-solving skills',
          'Excellent communication and leadership abilities'
        ],
        responsibilities: [
          'Define product vision and strategy',
          'Gather and prioritize product requirements',
          'Work closely with engineering, design, and marketing teams',
          'Analyze market trends and competitor products'
        ],
        benefits: [
          'Competitive compensation package',
          'Stock options',
          'Health and wellness benefits',
          'Professional development opportunities'
        ],
        postedDate: now.subtract(const Duration(days: 3)),
        applicationDeadline: now.add(const Duration(days: 27)),
        isBookmarked: true,
        isApplied: false,
        contactEmail: 'careers@innovativeproducts.com',
        contactPhone: '+82 10 5678 1234',
        websiteUrl: 'https://innovativeproducts.com',
      ),
    ];
  }
} 