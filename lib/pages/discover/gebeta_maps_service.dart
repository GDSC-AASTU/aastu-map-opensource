import 'dart:convert';
import 'package:http/http.dart' as http;

class GebetaMapsService {
  static const String _baseUrl = 'https://mapapi.gebeta.app/api/v1/route';
  static const String _apiKey = "YOUR_GEBETA_MAPS_API_KEY";
  
  // AASTU campus bounds in format: minLng,minLat,maxLng,maxLat
  // Using slightly expanded area around AASTU campus
  static const String _aastuBounds = '38.80341253750475,8.880065184857042,38.814904053887034,8.896581689125298';
  
  // Search places using Gebeta Maps geocoding API with bounds
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    print('[LOG GebetaSearch] ========= Searching for: $query');
    
    if (query.trim().isEmpty) {
      print('[LOG GebetaSearch] ========= Empty query, returning empty results');
      return [];
    }
    
    // First search: user query + 'aastu'
    final aastuQuery = "$query aastu";
    print('[LOG GebetaSearch] ========= First attempt with: $aastuQuery');
    
    final firstResults = await _performSearch(aastuQuery);
    
    // If we got results, return them
    if (firstResults.isNotEmpty) {
      print('[LOG GebetaSearch] ========= First attempt returned ${firstResults.length} results');
      return firstResults;
    }
    
    // Second search: just 'aastu'
    print('[LOG GebetaSearch] ========= No results from first attempt, trying with just "aastu"');
    final secondResults = await _performSearch('aastu');
    
    print('[LOG GebetaSearch] ========= Second attempt returned ${secondResults.length} results');
    return secondResults;
  }
  
  // Perform the actual API call to Gebeta Maps
  static Future<List<Map<String, dynamic>>> _performSearch(String query) async {
    try {
      // Using the bound parameter to limit search to AASTU area
      // Note: Using geocoding endpoint with bound parameter
      final Uri uri = Uri.parse('$_baseUrl/geocoding?name=${Uri.encodeComponent(query)}&bound=$_aastuBounds&apiKey=$_apiKey');
      print('[LOG GebetaSearch] ========= Request URI with AASTU bounds: $uri');
      
      // Add timeout to prevent long waits
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('[LOG GebetaSearch] ========= Request timed out after 10 seconds');
          return http.Response('{"error": "timeout"}', 408);
        },
      );
      
      print('[LOG GebetaSearch] ========= Response status code: ${response.statusCode}');
      print('[LOG GebetaSearch] ========= Response headers: ${response.headers}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        
        if (responseBody.isEmpty) {
          print('[LOG GebetaSearch] ========= Empty response body');
          return [];
        }
        
        try {
          final Map<String, dynamic> data = json.decode(responseBody);
          
          // Log a safe preview of the response data
          String dataSummary;
          try {
            dataSummary = json.encode(data).substring(0, min(200, json.encode(data).length));
          } catch (e) {
            dataSummary = "Could not format data summary: $e";
          }
          print('[LOG GebetaSearch] ========= Response data preview: $dataSummary...');
          
          // Check if the response has 'data' field (new structure)
          if (data['data'] != null && data['data'] is List) {
            final results = List<Map<String, dynamic>>.from(data['data']);
            print('[LOG GebetaSearch] ========= Found ${results.length} results in data field');
            
            // Print first result for debugging
            if (results.isNotEmpty) {
              print('[LOG GebetaSearch] ========= First result sample: ${results.first}');
            }
            
            return results;
          }
          // Fallback to checking 'results' field (old structure)
          else if (data['results'] != null && data['results'] is List) {
            final results = List<Map<String, dynamic>>.from(data['results']);
            print('[LOG GebetaSearch] ========= Found ${results.length} results in results field');
            
            // Print first result for debugging
            if (results.isNotEmpty) {
              print('[LOG GebetaSearch] ========= First result sample: ${results.first}');
            }
            
            return results;
          } else {
            print('[LOG GebetaSearch] ========= Data structure missing expected fields: ${data.keys.join(", ")}');
          }
        } catch (e) {
          print('[LOG GebetaSearch] ========= JSON parse error: $e');
          print('[LOG GebetaSearch] ========= Raw response: ${response.body.substring(0, min(500, response.body.length))}');
        }
      } else {
        print('[LOG GebetaSearch] ========= Error response: ${response.body}');
        
        // Try to parse error for more details
        try {
          final errorData = json.decode(response.body);
          print('[LOG GebetaSearch] ========= Error details: ${errorData['error']}');
        } catch (e) {
          print('[LOG GebetaSearch] ========= Could not parse error: $e');
        }
      }
      
      print('[LOG GebetaSearch] ========= No results found or invalid format');
      return [];
    } catch (e) {
      print('[LOG GebetaSearch] ========= Error searching Gebeta Maps: $e');
      return [];
    }
  }
  
  // Convert Gebeta Maps search result to a more usable format
  static List<Map<String, dynamic>> formatGebetaResults(List<Map<String, dynamic>> results) {
    print('[LOG GebetaFormat] ========= Formatting ${results.length} results');
    
    final formattedResults = results.map((result) {
      try {
        // Extract coordinates, handling different possible field names and capitalizations
        double? latitude;
        double? longitude;
        
        // Try different possible field names for latitude/longitude
        if (result['latitude'] != null && result['longitude'] != null) {
          latitude = result['latitude'];
          longitude = result['longitude'];
        } else if (result['lat'] != null && result['lng'] != null) {
          latitude = result['lat'];
          longitude = result['lng'];
        }
        
        // Extract city and country, handling different capitalizations
        String? city = result['City'] ?? result['city'];
        String? country = result['Country'] ?? result['country'];
        
        print('[LOG GebetaFormat] ========= Raw result: $result');
        print('[LOG GebetaFormat] ========= Extracted coordinates: $latitude, $longitude');
        
        final formatted = {
          'title': result['name'] ?? 'Unknown',
          'coordinates': latitude != null && longitude != null 
              ? [latitude, longitude] 
              : result['coordinates'] ?? [0.0, 0.0],
          'type': result['type'] ?? 'place',
          'city': city,
          'country': country,
        };
        print('[LOG GebetaFormat] ========= Formatted result: $formatted');
        return formatted;
      } catch (e) {
        print('[LOG GebetaFormat] ========= Error formatting result: $e, result: $result');
        return {
          'title': 'Error: Invalid format',
          'coordinates': [0.0, 0.0],
          'type': 'error',
        };
      }
    }).toList();
    
    print('[LOG GebetaFormat] ========= Total formatted results: ${formattedResults.length}');
    return formattedResults;
  }
  
  // Helper function to limit string length
  static int min(int a, int b) {
    return a < b ? a : b;
  }
} 