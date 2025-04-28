import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

class JobPost {
  final String title;
  final String company;
  final String location;
  final String payType;
  final String pay;
  final String workingHours;
  final String workingDays;
  final List<String> highlights;
  final DateTime postDate;
  final bool isUrgent;
  final double? distanceInKm;

  JobPost({
    required this.title,
    required this.company,
    required this.location,
    required this.payType,
    required this.pay,
    required this.workingHours,
    required this.workingDays,
    required this.highlights,
    required this.postDate,
    this.isUrgent = false,
    this.distanceInKm,
  });
}

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<JobPost> _jobs = [];
  List<JobPost> _filteredJobs = [];
  int _selectedCategoryIndex = 0;
  int _selectedLocationIndex = 0;
  bool _isLoading = true; // Track loading state
  
  // Add tracking for applied jobs and saved jobs
  final Set<String> _appliedJobs = <String>{};
  final Set<String> _savedJobs = <String>{};
  bool _showAppliedJobs = false;
  
  final List<String> _categories = [
    '전체',
    '알바',
    '채용',
    '오전',
    '오후',
    '주말',
    '재택',
    '급구',
  ];
  
  final List<String> _locations = [
    '전체',
    '강남구',
    '서초구',
    '송파구',
    '마포구',
    '용산구',
    '성동구',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Simulate network loading
    Future.delayed(Duration(milliseconds: 1500), () {
      _loadSampleJobs();
      setState(() {
        _isLoading = false;
        _filterJobs(); // Apply initial filtering
      });
    });
  }

  void _loadSampleJobs() {
    _jobs.addAll([
      JobPost(
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
      ),
      JobPost(
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
      ),
      JobPost(
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
      ),
      JobPost(
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
      ),
      JobPost(
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
      ),
    ]);
    _filteredJobs.addAll(_jobs);
  }

  void _filterJobs() {
    setState(() {
      List<JobPost> locationFiltered = _selectedLocationIndex == 0
          ? List.from(_jobs)
          : _jobs.where((job) => job.location.contains(_locations[_selectedLocationIndex])).toList();
          
      if (_selectedCategoryIndex == 0 && !_showAppliedJobs) {
        _filteredJobs = locationFiltered;
      } else {
        String categoryFilter = _categories[_selectedCategoryIndex].toLowerCase();
        
        // First filter by category
        var categoryFiltered = _selectedCategoryIndex == 0 
            ? locationFiltered 
            : locationFiltered.where((job) {
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
              }).toList();
              
        // Then filter by applied status if needed
        if (_showAppliedJobs) {
          _filteredJobs = categoryFiltered.where((job) => 
            _appliedJobs.contains(job.title)).toList();
        } else {
          _filteredJobs = categoryFiltered;
        }
      }
    });
  }

  Future<void> _refreshJobs() async {
    setState(() {
      _isLoading = true;
    });
    
    await Future.delayed(Duration(milliseconds: 1500));
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: theme.scaffoldBackgroundColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 20,
          toolbarHeight: 48,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '동네알바',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
                size: 22,
              ),
              onPressed: () {},
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
                size: 22,
              ),
              onPressed: () {},
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            const SizedBox(width: 12),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Container(
              height: 1,
              color: theme.dividerColor.withOpacity(0.2),
            ),
          ),
        ),
        body: Column(
          children: [
            _buildLocationBar(),
            _buildCategoryBar(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _filteredJobs.isEmpty
                      ? _buildEmptyState()
                      : _buildJobList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: theme.colorScheme.primary,
          elevation: 2,
          label: Row(
            children: [
              Icon(Icons.add, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text(
                '알바 공고 올리기',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildLocationBar() {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _locations.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedLocationIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedLocationIndex = index;
                _filterJobs();
              });
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _locations[index],
                style: TextStyle(
                  color: isSelected ? 
                    theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryBar() {
    final theme = Theme.of(context);
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.03),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
                _filterJobs();
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? 
                  theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? 
                    theme.colorScheme.primary : theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color: isSelected ? 
                    theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline_rounded,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            '조건에 맞는 알바가 없습니다',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '다른 필터를 선택하거나 직접 채용 공고를 올려보세요!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedCategoryIndex = 0;
                _selectedLocationIndex = 0;
                _filterJobs();
              });
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: Text('필터 초기화'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: _buildJobItemSkeleton(),
        );
      },
    );
  }

  Widget _buildJobItemSkeleton() {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with urgent tag and distance
            Row(
              children: [
                Container(
                  width: 50,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 12),

            // Job title (2 lines for longer titles)
            Container(
              height: 20,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 6),
            Container(
              height: 20,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 10),

            // Company and location
            Row(
              children: [
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    height: 4,
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Pay
            Container(
              width: 120,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Divider
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.white,
            ),
            SizedBox(height: 12),
            
            // Working hours and days
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Highlights
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(3, (index) => 
                Container(
                  width: 80,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Apply button
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 16),
            
            // Posted time and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 70,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList() {
    return RefreshIndicator(
      onRefresh: _refreshJobs,
      child: ListView.builder(
        padding: EdgeInsets.only(top: 12, bottom: 80),
        itemCount: _filteredJobs.length,
        itemBuilder: (context, index) {
          return _buildJobItem(_filteredJobs[index]);
        },
      ),
    );
  }

  Widget _buildJobItem(JobPost job) {
    final theme = Theme.of(context);
    final isApplied = _appliedJobs.contains(job.title);
    final isSaved = _savedJobs.contains(job.title);
    
    Color accentColor = job.payType == '시급' 
        ? theme.colorScheme.primary
        : theme.colorScheme.tertiary;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (job.isUrgent)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  margin: EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '급구',
                                    style: TextStyle(
                                      color: Colors.red.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (job.distanceInKm != null)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${job.distanceInKm}km',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            job.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              fontSize: 18,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                job.company,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  '•',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              Text(
                                job.location,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${job.payType} ${job.pay}',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(height: 1, thickness: 1, color: theme.dividerColor),
                SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(Icons.access_time_rounded, job.workingHours),
                    SizedBox(width: 8),
                    _buildInfoChip(Icons.calendar_today_rounded, job.workingDays),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: job.highlights.map((highlight) => _buildHighlightChip(highlight)).toList(),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: isApplied ? null : () => _applyForJob(job),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApplied ? Colors.grey[300] : accentColor,
                    foregroundColor: isApplied ? Colors.grey[600] : theme.colorScheme.onPrimary,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isApplied ? '지원 완료' : '지원하기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getTimeAgo(job.postDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_outline,
                            size: 20, 
                            color: isSaved ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                          onPressed: () => _toggleSaveJob(job),
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        SizedBox(width: 16),
                        IconButton(
                          icon: Icon(Icons.share_rounded, 
                            size: 20, 
                            color: theme.colorScheme.onSurfaceVariant),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('공유 기능이 준비 중입니다'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightChip(String text) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 1) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  // Add method to track job applications
  void _applyForJob(JobPost job) {
    setState(() {
      // In a real app, this would make an API call to submit the application
      if (!_appliedJobs.contains(job.title)) {
        _appliedJobs.add(job.title);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${job.title}에 지원 완료!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: '확인',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        // Already applied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미 지원한 공고입니다'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
  
  // Add method to save/bookmark jobs
  void _toggleSaveJob(JobPost job) {
    setState(() {
      if (_savedJobs.contains(job.title)) {
        _savedJobs.remove(job.title);
      } else {
        _savedJobs.add(job.title);
      }
    });
  }
} 