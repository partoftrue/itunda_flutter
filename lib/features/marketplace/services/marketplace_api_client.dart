import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_item.dart';
import '../models/seller.dart';
import '../models/review.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';

class MarketplaceApiClient {
  final http.Client _httpClient;
  final String _baseUrl = ApiConfig.baseUrl;

  MarketplaceApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  // Get all marketplace items with optional filtering
  Future<List<MarketItem>> getItems({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? location,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Auth removed: no token required
      final queryParams = {
        if (category != null && category != '전체') 'category': category,
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        if (sortBy != null) 'sort_by': sortBy,
        if (location != null) 'location': location,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$_baseUrl/market/items').replace(queryParameters: queryParams);
      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List)
            .map((item) => MarketItem.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get market items: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to get market items: $e');
    }
  }

  // Get a specific item by ID
  Future<MarketItem> getItemById(String itemId) async {
    try {
      // Auth removed: no token required
      final uri = Uri.parse('$_baseUrl/market/items/$itemId');
      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MarketItem.fromJson(data);
      } else {
        throw Exception('Failed to get item details: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to get item details: $e');
    }
  }

  // Get bookmarked items for the current user
  Future<List<MarketItem>> getBookmarkedItems() async {
    try {
      // Auth removed: no token required
      

      final uri = Uri.parse('$_baseUrl/market/bookmarks');
      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',

        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List)
            .map((item) => MarketItem.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get bookmarked items: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to get bookmarked items: $e');
    }
  }

  // Add or remove a bookmark
  Future<bool> toggleBookmark(String itemId, bool isBookmarked) async {
    try {
      // Auth removed: no token required
      

      final uri = Uri.parse('$_baseUrl/market/bookmarks/$itemId');
      final response = isBookmarked
          ? await _httpClient.post(
              uri,
              headers: {
                'Content-Type': 'application/json',
      
              },
            )
          : await _httpClient.delete(
              uri,
              headers: {
                'Content-Type': 'application/json',
      
              },
            );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to update bookmark: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to update bookmark: $e');
    }
  }

  // Get seller information
  Future<Seller> getSeller(String sellerId) async {
    try {
      // Auth removed: no token required
      final uri = Uri.parse('$_baseUrl/market/sellers/$sellerId');
      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Seller.fromJson(data);
      } else {
        throw Exception('Failed to get seller details: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to get seller details: $e');
    }
  }

  // Get reviews for a seller
  Future<List<Review>> getSellerReviews(String sellerId) async {
    try {
      // Auth removed: no token required
      final uri = Uri.parse('$_baseUrl/market/sellers/$sellerId/reviews');
      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['reviews'] as List)
            .map((review) => Review.fromJson(review))
            .toList();
      } else {
        throw Exception('Failed to get seller reviews: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to get seller reviews: $e');
    }
  }

  // Search for items
  Future<List<MarketItem>> searchItems(String query) async {
    try {
      // Auth removed: no token required
      final uri = Uri.parse('$_baseUrl/market/search').replace(
        queryParameters: {'q': query},
      );
      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List)
            .map((item) => MarketItem.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to search items: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to search items: $e');
    }
  }

  // Create a new market item
  Future<MarketItem> createItem(Map<String, dynamic> itemData, List<String> imagePaths) async {
    try {
      // Auth removed: no token required
      

      // For file uploads, we need to use a multipart request
      final uri = Uri.parse('$_baseUrl/market/items');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers.addAll({
        
      });
      
      // Add item data as fields
      itemData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });
      
      // Add images as files
      for (var i = 0; i < imagePaths.length; i++) {
        final file = await http.MultipartFile.fromPath(
          'images[$i]',
          imagePaths[i],
        );
        request.files.add(file);
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return MarketItem.fromJson(data);
      } else {
        throw Exception('Failed to create item: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  // Update an existing market item
  Future<MarketItem> updateItem(String itemId, Map<String, dynamic> updates, List<String>? newImagePaths) async {
    try {
      // Auth removed: no token required
      

      final uri = Uri.parse('$_baseUrl/market/items/$itemId');
      
      if (newImagePaths != null && newImagePaths.isNotEmpty) {
        // If we have new images, use multipart request
        final request = http.MultipartRequest('PUT', uri);
        
        request.headers.addAll({

        });
        
        // Add item data as fields
        updates.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
        
        // Add images as files
        for (var i = 0; i < newImagePaths.length; i++) {
          final file = await http.MultipartFile.fromPath(
            'images[$i]',
            newImagePaths[i],
          );
          request.files.add(file);
        }
        
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return MarketItem.fromJson(data);
        } else {
          throw Exception('Failed to update item: ${response.reasonPhrase}');
        }
      } else {
        // If no new images, use a regular PUT request
        final response = await _httpClient.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
  
          },
          body: json.encode(updates),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return MarketItem.fromJson(data);
        } else {
          throw Exception('Failed to update item: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // Delete a market item
  Future<bool> deleteItem(String itemId) async {
    try {
      // Auth removed: no token required
      

      final uri = Uri.parse('$_baseUrl/market/items/$itemId');
      final response = await _httpClient.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',

        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete item: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  // Report an item
  Future<bool> reportItem(String itemId, String reason, String description) async {
    try {
      // Auth removed: no token required
      

      final uri = Uri.parse('$_baseUrl/market/items/$itemId/report');
      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',

        },
        body: json.encode({
          'reason': reason,
          'description': description,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to report item: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to report item: $e');
    }
  }
  
  // Get trending items
  Future<List<MarketItem>> getTrendingItems({int limit = 10}) async {
    try {
      // Auth removed: no token required
      final uri = Uri.parse('$_baseUrl/market/trending').replace(
        queryParameters: {'limit': limit.toString()},
      );
      
      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List)
            .map((item) => MarketItem.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get trending items: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to get trending items: $e');
    }
  }
} 