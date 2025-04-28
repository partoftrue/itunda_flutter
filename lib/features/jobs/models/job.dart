import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'job_category.dart';
import 'job_type.dart';

class Job extends Equatable {
  final String id;
  final String title;
  final String companyName;
  final String? companyLogo;
  final String location;
  final double salary;
  final bool isSalaryNegotiable;
  final JobType jobType;
  final JobCategory category;
  final String description;
  final List<String> requirements;
  final List<String> responsibilities;
  final List<String> benefits;
  final DateTime postedDate;
  final DateTime applicationDeadline;
  final bool isBookmarked;
  final bool isApplied;
  final String contactEmail;
  final String? contactPhone;
  final String? websiteUrl;

  const Job({
    required this.id,
    required this.title,
    required this.companyName,
    this.companyLogo,
    required this.location,
    required this.salary,
    this.isSalaryNegotiable = false,
    required this.jobType,
    required this.category,
    required this.description,
    required this.requirements,
    required this.responsibilities,
    required this.benefits,
    required this.postedDate,
    required this.applicationDeadline,
    this.isBookmarked = false,
    this.isApplied = false,
    required this.contactEmail,
    this.contactPhone,
    this.websiteUrl,
  });

  String get formattedSalary {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return '${formatter.format(salary)}${isSalaryNegotiable ? ' (Negotiable)' : ''}';
  }

  String get timeAgo {
    final difference = DateTime.now().difference(postedDate);
    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(postedDate);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
  }

  String get remainingDays {
    final difference = applicationDeadline.difference(DateTime.now());
    if (difference.isNegative) {
      return 'Expired';
    } else if (difference.inDays == 0) {
      return 'Last day';
    } else {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} remaining';
    }
  }

  bool get isExpired => DateTime.now().isAfter(applicationDeadline);

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      title: json['title'] as String,
      companyName: json['companyName'] as String,
      companyLogo: json['companyLogo'] as String?,
      location: json['location'] as String,
      salary: (json['salary'] as num).toDouble(),
      isSalaryNegotiable: json['isSalaryNegotiable'] as bool? ?? false,
      jobType: JobTypeExtension.fromString(json['jobType'] as String?),
      category: JobCategory.fromJson(json['category'] as Map<String, dynamic>),
      description: json['description'] as String,
      requirements: List<String>.from(json['requirements'] as List),
      responsibilities: List<String>.from(json['responsibilities'] as List),
      benefits: List<String>.from(json['benefits'] as List),
      postedDate: DateTime.parse(json['postedDate'] as String),
      applicationDeadline: DateTime.parse(json['applicationDeadline'] as String),
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      isApplied: json['isApplied'] as bool? ?? false,
      contactEmail: json['contactEmail'] as String,
      contactPhone: json['contactPhone'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'location': location,
      'salary': salary,
      'isSalaryNegotiable': isSalaryNegotiable,
      'jobType': jobType.name,
      'category': category.toJson(),
      'description': description,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'benefits': benefits,
      'postedDate': postedDate.toIso8601String(),
      'applicationDeadline': applicationDeadline.toIso8601String(),
      'isBookmarked': isBookmarked,
      'isApplied': isApplied,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'websiteUrl': websiteUrl,
    };
  }

  Job copyWith({
    String? id,
    String? title,
    String? companyName,
    String? companyLogo,
    String? location,
    double? salary,
    bool? isSalaryNegotiable,
    JobType? jobType,
    JobCategory? category,
    String? description,
    List<String>? requirements,
    List<String>? responsibilities,
    List<String>? benefits,
    DateTime? postedDate,
    DateTime? applicationDeadline,
    bool? isBookmarked,
    bool? isApplied,
    String? contactEmail,
    String? contactPhone,
    String? websiteUrl,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      isSalaryNegotiable: isSalaryNegotiable ?? this.isSalaryNegotiable,
      jobType: jobType ?? this.jobType,
      category: category ?? this.category,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      responsibilities: responsibilities ?? this.responsibilities,
      benefits: benefits ?? this.benefits,
      postedDate: postedDate ?? this.postedDate,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isApplied: isApplied ?? this.isApplied,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      websiteUrl: websiteUrl ?? this.websiteUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        companyName,
        companyLogo,
        location,
        salary,
        isSalaryNegotiable,
        jobType,
        category,
        description,
        requirements,
        responsibilities,
        benefits,
        postedDate,
        applicationDeadline,
        isBookmarked,
        isApplied,
        contactEmail,
        contactPhone,
        websiteUrl,
      ];
} 