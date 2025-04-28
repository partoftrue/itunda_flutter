import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class JobCategory extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final Color color;
  final int jobCount;

  const JobCategory({
    required this.id,
    required this.name,
    this.icon,
    required this.color,
    this.jobCount = 0,
  });

  factory JobCategory.fromJson(Map<String, dynamic> json) {
    return JobCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: Color(json['color'] as int),
      jobCount: json['jobCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.value,
      'jobCount': jobCount,
    };
  }

  JobCategory copyWith({
    String? id,
    String? name,
    String? icon,
    Color? color,
    int? jobCount,
  }) {
    return JobCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      jobCount: jobCount ?? this.jobCount,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, color, jobCount];

  static List<JobCategory> getDefaultCategories() {
    return [
      JobCategory(
        id: '1',
        name: 'Technology',
        icon: 'assets/icons/technology.png',
        color: Colors.blue,
        jobCount: 120,
      ),
      JobCategory(
        id: '2',
        name: 'Healthcare',
        icon: 'assets/icons/healthcare.png',
        color: Colors.green,
        jobCount: 85,
      ),
      JobCategory(
        id: '3',
        name: 'Education',
        icon: 'assets/icons/education.png',
        color: Colors.orange,
        jobCount: 64,
      ),
      JobCategory(
        id: '4',
        name: 'Finance',
        icon: 'assets/icons/finance.png',
        color: Colors.purple,
        jobCount: 92,
      ),
      JobCategory(
        id: '5',
        name: 'Marketing',
        icon: 'assets/icons/marketing.png',
        color: Colors.red,
        jobCount: 78,
      ),
      JobCategory(
        id: '6',
        name: 'Design',
        icon: 'assets/icons/design.png',
        color: Colors.teal,
        jobCount: 56,
      ),
      JobCategory(
        id: '7',
        name: 'Hospitality',
        icon: 'assets/icons/hospitality.png',
        color: Colors.amber,
        jobCount: 47,
      ),
      JobCategory(
        id: '8',
        name: 'Retail',
        icon: 'assets/icons/retail.png',
        color: Colors.indigo,
        jobCount: 105,
      ),
    ];
  }
} 