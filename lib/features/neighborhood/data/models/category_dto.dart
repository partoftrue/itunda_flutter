import 'package:finance_app/features/neighborhood/domain/models/category.dart';

/// Data Transfer Object for categories from the API
class CategoryDTO {
  final String id;
  final String name;
  final int postCount;
  
  CategoryDTO({
    required this.id,
    required this.name,
    required this.postCount,
  });
  
  /// Convert from JSON to CategoryDTO
  factory CategoryDTO.fromJson(Map<String, dynamic> json) {
    return CategoryDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      postCount: json['postCount'] as int? ?? 0,
    );
  }
  
  /// Convert CategoryDTO to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'postCount': postCount,
    };
  }
  
  /// Convert CategoryDTO to domain Category model
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      postCount: postCount,
    );
  }
  
  /// Create CategoryDTO from domain Category model
  factory CategoryDTO.fromDomain(Category category) {
    return CategoryDTO(
      id: category.id,
      name: category.name,
      postCount: category.postCount,
    );
  }
} 