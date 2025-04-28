import 'package:flutter/material.dart';

class JobPost {
  final String id;
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
  final String? companyLogo;
  final String? description;
  final String? contactInfo;
  final int? views;
  final int? applications;
  final bool isSaved;

  JobPost({
    required this.id,
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
    this.companyLogo,
    this.description,
    this.contactInfo,
    this.views,
    this.applications,
    this.isSaved = false,
  });

  // Create a copy of the job post with some fields changed
  JobPost copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? payType,
    String? pay,
    String? workingHours,
    String? workingDays,
    List<String>? highlights,
    DateTime? postDate,
    bool? isUrgent,
    double? distanceInKm,
    String? companyLogo,
    String? description,
    String? contactInfo,
    int? views,
    int? applications,
    bool? isSaved,
  }) {
    return JobPost(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      payType: payType ?? this.payType,
      pay: pay ?? this.pay,
      workingHours: workingHours ?? this.workingHours,
      workingDays: workingDays ?? this.workingDays,
      highlights: highlights ?? this.highlights,
      postDate: postDate ?? this.postDate,
      isUrgent: isUrgent ?? this.isUrgent,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      companyLogo: companyLogo ?? this.companyLogo,
      description: description ?? this.description,
      contactInfo: contactInfo ?? this.contactInfo,
      views: views ?? this.views,
      applications: applications ?? this.applications,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  // Create a JobPost from JSON data
  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      location: json['location'] as String,
      payType: json['payType'] as String,
      pay: json['pay'] as String,
      workingHours: json['workingHours'] as String,
      workingDays: json['workingDays'] as String,
      highlights: List<String>.from(json['highlights'] as List),
      postDate: DateTime.parse(json['postDate'] as String),
      isUrgent: json['isUrgent'] as bool? ?? false,
      distanceInKm: json['distanceInKm'] as double?,
      companyLogo: json['companyLogo'] as String?,
      description: json['description'] as String?,
      contactInfo: json['contactInfo'] as String?,
      views: json['views'] as int?,
      applications: json['applications'] as int?,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }

  // Convert JobPost to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'payType': payType,
      'pay': pay,
      'workingHours': workingHours,
      'workingDays': workingDays,
      'highlights': highlights,
      'postDate': postDate.toIso8601String(),
      'isUrgent': isUrgent,
      'distanceInKm': distanceInKm,
      'companyLogo': companyLogo,
      'description': description,
      'contactInfo': contactInfo,
      'views': views,
      'applications': applications,
      'isSaved': isSaved,
    };
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(postDate);

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
  
  // Calculate match score based on job attributes (0-100)
  int calculateMatchScore() {
    // This would normally use user preferences and job requirements
    // For now, we'll use a simplified algorithm for demonstration
    
    int score = 70; // Base score
    
    // Distance factor (closer is better)
    if (distanceInKm != null) {
      if (distanceInKm! < 1) {
        score += 15; // Very close
      } else if (distanceInKm! < 3) {
        score += 10; // Close
      } else if (distanceInKm! < 5) {
        score += 5; // Moderate distance
      }
    }
    
    // Recent posting bonus
    final daysSincePosted = DateTime.now().difference(postDate).inDays;
    if (daysSincePosted < 1) {
      score += 10; // Posted today
    } else if (daysSincePosted < 3) {
      score += 5; // Posted in last 3 days
    }
    
    // Highlights that might match user preferences
    if (highlights.any((h) => h.contains('식사제공'))) {
      score += 2;
    }
    if (highlights.any((h) => h.contains('주차'))) {
      score += 2;
    }
    if (highlights.any((h) => h.contains('경력자'))) {
      score -= 5; // Assuming user is not experienced
    }
    
    // Cap the score at 100
    return score > 100 ? 100 : score;
  }
} 