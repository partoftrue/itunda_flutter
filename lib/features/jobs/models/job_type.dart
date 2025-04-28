import 'package:flutter/material.dart';

enum JobType {
  fullTime,
  partTime,
  contract,
  freelance,
  internship,
}

extension JobTypeExtension on JobType {
  String get name {
    switch (this) {
      case JobType.fullTime:
        return 'Full-time';
      case JobType.partTime:
        return 'Part-time';
      case JobType.contract:
        return 'Contract';
      case JobType.freelance:
        return 'Freelance';
      case JobType.internship:
        return 'Internship';
    }
  }

  Color get color {
    switch (this) {
      case JobType.fullTime:
        return Colors.blue;
      case JobType.partTime:
        return Colors.amber;
      case JobType.contract:
        return Colors.purple;
      case JobType.freelance:
        return Colors.teal;
      case JobType.internship:
        return Colors.green;
    }
  }

  static JobType fromString(String? value) {
    if (value == null) return JobType.fullTime;
    
    switch (value.toLowerCase()) {
      case 'full-time':
      case 'fulltime':
      case 'full time':
        return JobType.fullTime;
      case 'part-time':
      case 'parttime':
      case 'part time':
        return JobType.partTime;
      case 'contract':
        return JobType.contract;
      case 'freelance':
        return JobType.freelance;
      case 'internship':
        return JobType.internship;
      default:
        return JobType.fullTime;
    }
  }
} 