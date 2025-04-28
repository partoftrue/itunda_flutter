import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_item.dart';
import '../models/market_profile.dart';

class MarketplaceService {
  final String baseUrl = 'https://api.example.com/marketplace'; // Replace with actual API URL

  // Fetch market items
  Future<List<MarketItem>> getMarketItems({
    String? category,
    String? query,
    int page = 1,
    int limit = 20,
    String? sortBy,
    bool? ascending,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (category != null) queryParams['category'] = category;
    if (query != null) queryParams['query'] = query;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (ascending != null) queryParams['ascending'] = ascending.toString();
    
    final response = await http.get(
      Uri.parse('$baseUrl/items').replace(queryParameters: queryParams),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['items'];
      return data.map((item) => MarketItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load market items: ${response.statusCode}');
    }
  }
  
  // Get a single market item by ID
  Future<MarketItem> getMarketItem(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/items/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return MarketItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load market item: ${response.statusCode}');
    }
  }
  
  // Get seller profile
  Future<MarketProfile> getSellerProfile(String sellerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/sellers/$sellerId'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return MarketProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load seller profile: ${response.statusCode}');
    }
  }
  
  // Post a new market item
  Future<MarketItem> createMarketItem(MarketItem item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );
    
    if (response.statusCode == 201) {
      return MarketItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create market item: ${response.statusCode}');
    }
  }
  
  // Update a market item
  Future<MarketItem> updateMarketItem(String id, MarketItem item) async {
    final response = await http.put(
      Uri.parse('$baseUrl/items/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );
    
    if (response.statusCode == 200) {
      return MarketItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update market item: ${response.statusCode}');
    }
  }
  
  // Delete a market item
  Future<void> deleteMarketItem(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/items/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete market item: ${response.statusCode}');
    }
  }
  
  // Toggle favorite status
  Future<bool> toggleFavorite(String itemId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items/$itemId/favorite'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['isFavorite'] as bool;
    } else {
      throw Exception('Failed to toggle favorite: ${response.statusCode}');
    }
  }
} 