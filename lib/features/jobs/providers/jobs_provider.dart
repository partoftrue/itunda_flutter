import 'package:flutter/material.dart';
import '../models/job_post.dart';

class JobsProvider extends ChangeNotifier {
  final List<JobPost> _allJobs = [];
  final List<JobPost> _filteredJobs = [];
  bool _isLoading = true;
  String? _error;
  int _selectedCategoryIndex = 0;
  int _selectedLocationIndex = 0;
  
  // Categories for filtering
  final List<String> categories = [
    '전체',
    '알바',
    '채용',
    '오전',
    '오후',
    '주말',
    '재택',
    '급구',
  ];
  
  // Locations for filtering
  final List<String> locations = [
    '전체',
    '강남구',
    '서초구',
    '송파구',
    '마포구',
    '용산구',
    '성동구',
  ];

  // Getters
  List<JobPost> get jobs => List.unmodifiable(_allJobs);
  List<JobPost> get filteredJobs => List.unmodifiable(_filteredJobs);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  int get selectedLocationIndex => _selectedLocationIndex;

  // Initialize by loading mock data
  Future<void> loadJobs() async {
    _setLoading(true);
    _error = null;
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Load mock data
      _allJobs.clear();
      _allJobs.addAll(_getMockJobs());
      
      // Apply filters
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }
  
  // Refresh jobs
  Future<void> refreshJobs() async {
    _setLoading(true);
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // In a real app, we would fetch fresh data from API
      // For now, we'll just reuse our mock data
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }
  
  // Set category filter
  void setCategoryFilter(int index) {
    if (_selectedCategoryIndex == index) return;
    
    _selectedCategoryIndex = index;
    _applyFilters();
    notifyListeners();
  }
  
  // Set location filter
  void setLocationFilter(int index) {
    if (_selectedLocationIndex == index) return;
    
    _selectedLocationIndex = index;
    _applyFilters();
    notifyListeners();
  }
  
  // Toggle job bookmark
  void toggleBookmark(String jobId) {
    final jobIndex = _allJobs.indexWhere((job) => job.id == jobId);
    if (jobIndex >= 0) {
      _allJobs[jobIndex] = _allJobs[jobIndex].copyWith(
        isSaved: !_allJobs[jobIndex].isSaved
      );
      
      // Also update in filtered list if present
      final filteredIndex = _filteredJobs.indexWhere((job) => job.id == jobId);
      if (filteredIndex >= 0) {
        _filteredJobs[filteredIndex] = _filteredJobs[filteredIndex].copyWith(
          isSaved: !_filteredJobs[filteredIndex].isSaved
        );
      }
      
      notifyListeners();
    }
  }
  
  // Reset all filters
  void resetFilters() {
    _selectedCategoryIndex = 0;
    _selectedLocationIndex = 0;
    _applyFilters();
    notifyListeners();
  }
  
  // Apply filters to jobs list
  void _applyFilters() {
    // First filter by location
    List<JobPost> locationFiltered = _selectedLocationIndex == 0
        ? List.from(_allJobs) // All locations
        : _allJobs.where((job) => job.location.contains(locations[_selectedLocationIndex])).toList();
    
    // Then filter by category
    if (_selectedCategoryIndex == 0) {
      // Show all jobs
      _filteredJobs.clear();
      _filteredJobs.addAll(locationFiltered);
    } else {
      // Filter based on category
      String categoryFilter = categories[_selectedCategoryIndex].toLowerCase();
      _filteredJobs.clear();
      _filteredJobs.addAll(locationFiltered.where((job) {
        if (categoryFilter == '알바') {
          return job.payType.toLowerCase() == '시급';
        } else if (categoryFilter == '채용') {
          return job.payType.toLowerCase() == '월급';
        } else if (categoryFilter == '오전') {
          return job.workingHours.toLowerCase().contains('오전') || 
                int.parse(job.workingHours.split(':')[0]) < 12;
        } else if (categoryFilter == '오후') {
          return job.workingHours.toLowerCase().contains('오후') || 
                int.parse(job.workingHours.split(':')[0]) >= 12;
        } else if (categoryFilter == '주말') {
          return job.workingDays.toLowerCase().contains('토') || 
                job.workingDays.toLowerCase().contains('일');
        } else if (categoryFilter == '재택') {
          return job.highlights.any((highlight) => 
              highlight.toLowerCase().contains('재택'));
        } else if (categoryFilter == '급구') {
          return job.isUrgent;
        }
        return false;
      }));
    }
  }
  
  // Update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Mock data for testing
  List<JobPost> _getMockJobs() {
    return [
      JobPost(
        id: '1',
        title: '직원 구합니다. 오전/오후 시간 협의 가능',
        company: '카페 데일리',
        location: '강남구 역삼동',
        payType: '시급',
        pay: '11,000원',
        workingHours: '09:00 - 18:00',
        workingDays: '월~금',
        highlights: ['즉시채용', '식사제공', '주차가능'],
        postDate: DateTime.now().subtract(Duration(hours: 3)),
        isUrgent: true,
        distanceInKm: 0.8,
        applications: 3,
        views: 42,
      ),
      JobPost(
        id: '2',
        title: '주말 서빙 알바생 모집합니다',
        company: '맛나 돈까스',
        location: '강남구 신사동',
        payType: '시급',
        pay: '10,000원',
        workingHours: '17:00 - 22:00',
        workingDays: '금,토,일',
        highlights: ['주말알바', '식사제공'],
        postDate: DateTime.now().subtract(Duration(days: 1)),
        distanceInKm: 1.2,
        applications: 5,
        views: 68,
      ),
      JobPost(
        id: '3',
        title: '편의점 야간 알바 구합니다',
        company: 'GS25 역삼점',
        location: '강남구 역삼동',
        payType: '시급',
        pay: '12,000원',
        workingHours: '22:00 - 07:00',
        workingDays: '월~일 협의',
        highlights: ['야간근무', '급구'],
        postDate: DateTime.now().subtract(Duration(days: 1)),
        isUrgent: true,
        distanceInKm: 0.5,
        applications: 2,
        views: 31,
      ),
      JobPost(
        id: '4',
        title: '웹디자이너 파트타임 채용',
        company: '디자인 스튜디오',
        location: '서초구 서초동',
        payType: '월급',
        pay: '250만원',
        workingHours: '10:00 - 17:00',
        workingDays: '월~금',
        highlights: ['재택가능', '경력자우대', '디자인 전공'],
        postDate: DateTime.now().subtract(Duration(days: 2)),
        distanceInKm: 2.4,
        applications: 8,
        views: 112,
      ),
      JobPost(
        id: '5',
        title: '오전 시간대 카운터 직원 모집',
        company: '소소한 베이커리',
        location: '마포구 망원동',
        payType: '시급',
        pay: '10,500원',
        workingHours: '08:00 - 13:00',
        workingDays: '월~금',
        highlights: ['오전알바', '근무시간 조정가능'],
        postDate: DateTime.now().subtract(Duration(days: 3)),
        distanceInKm: 4.7,
        applications: 6,
        views: 89,
      ),
    ];
  }
} 