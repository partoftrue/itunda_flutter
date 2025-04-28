import 'package:flutter/foundation.dart';

@immutable
class MenuItemOption {
  final String id;
  final String name;
  final bool required;
  final bool multiSelect;
  final List<OptionItem> items;

  const MenuItemOption({
    required this.id,
    required this.name,
    required this.required,
    required this.multiSelect,
    required this.items,
  });

  MenuItemOption copyWith({
    String? id,
    String? name,
    bool? required,
    bool? multiSelect,
    List<OptionItem>? items,
  }) {
    return MenuItemOption(
      id: id ?? this.id,
      name: name ?? this.name,
      required: required ?? this.required,
      multiSelect: multiSelect ?? this.multiSelect,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItemOption && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'required': required,
      'multiSelect': multiSelect,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  factory MenuItemOption.fromJson(Map<String, dynamic> json) {
    return MenuItemOption(
      id: json['id'] as String,
      name: json['name'] as String,
      required: json['required'] as bool,
      multiSelect: json['multiSelect'] as bool,
      items: (json['items'] as List<dynamic>)
          .map((e) => OptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

@immutable
class OptionItem {
  final String id;
  final String name;
  final int price;

  const OptionItem({
    required this.id,
    required this.name,
    required this.price,
  });

  OptionItem copyWith({
    String? id,
    String? name,
    int? price,
  }) {
    return OptionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptionItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  factory OptionItem.fromJson(Map<String, dynamic> json) {
    return OptionItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
    );
  }
} 