import 'package:cloud_firestore/cloud_firestore.dart';
import 'special_location_model.dart';

class PlacesSearchService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Search for places in Firebase and special locations
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    print('[LOG PlacesSearch] ========= Searching for: $query');
    
    if (query.trim().isEmpty) {
      print('[LOG PlacesSearch] ========= Empty query, returning empty results');
      return [];
    }
    
    final List<Map<String, dynamic>> results = [];
    
    // Search in Firestore
    try {
      print('[LOG PlacesSearch] ========= Searching in Firestore');
      final firestoreResults = await _searchFirestore(query);
      print('[LOG PlacesSearch] ========= Found ${firestoreResults.length} results in Firestore');
      results.addAll(firestoreResults);
    } catch (e) {
      print('[LOG PlacesSearch] ========= Error searching Firestore: $e');
    }
    
    // Search in special locations
    print('[LOG PlacesSearch] ========= Searching in special locations');
    final specialResults = _searchSpecialLocations(query);
    print('[LOG PlacesSearch] ========= Found ${specialResults.length} results in special locations');
    results.addAll(specialResults);
    
    print('[LOG PlacesSearch] ========= Total results found: ${results.length}');
    return results;
  }
  
  // Search in Firebase Firestore
  static Future<List<Map<String, dynamic>>> _searchFirestore(String query) async {
    final List<Map<String, dynamic>> results = [];
    final lowercaseQuery = query.toLowerCase();
    
    print('[LOG FirestoreSearch] ========= Searching with lowercase query: $lowercaseQuery');
    
    try {
      // Get all places and filter manually for better case-insensitive search
      print('[LOG FirestoreSearch] ========= Getting places collection to search locally');
      final placesSnapshot = await _firestore
          .collection('places')
          .limit(50) // Limit to avoid fetching too many documents
          .get();
      
      print('[LOG FirestoreSearch] ========= Got ${placesSnapshot.docs.length} places to search through');
      
      // Process results and filter manually for more flexible search
      for (var doc in placesSnapshot.docs) {
        final data = doc.data();
        final String title = (data['title'] ?? '').toString().toLowerCase();
        final String description = (data['description'] ?? '').toString().toLowerCase();
        
        if (title.contains(lowercaseQuery) || description.contains(lowercaseQuery)) {
          print('[LOG FirestoreSearch] ========= Found match: ${doc.id}, title: ${data['title']}');
          results.add({
            'id': doc.id,
            'source': 'firebase',
            ...data,
          });
          
          // Limit results to 10 max
          if (results.length >= 10) {
            print('[LOG FirestoreSearch] ========= Reached max results limit (10)');
            break;
          }
        }
      }
    } catch (e) {
      print('[LOG FirestoreSearch] ========= Error in Firestore search: $e');
    }
    
    print('[LOG FirestoreSearch] ========= Total Firestore results: ${results.length}');
    return results;
  }
  
  // Search in special locations
  static List<Map<String, dynamic>> _searchSpecialLocations(String query) {
    final List<Map<String, dynamic>> results = [];
    final lowercaseQuery = query.toLowerCase();
    
    print('[LOG SpecialSearch] ========= Searching with lowercase query: $lowercaseQuery');
    print('[LOG SpecialSearch] ========= Total special locations: ${specialLocations.length}');
    
    for (var location in specialLocations) {
      final bool titleMatch = location.title.toLowerCase().contains(lowercaseQuery);
      final bool descriptionMatch = location.description.toLowerCase().contains(lowercaseQuery);
      final bool typeMatch = location.type.toLowerCase().contains(lowercaseQuery);
      
      if (titleMatch || descriptionMatch || typeMatch) {
        print('[LOG SpecialSearch] ========= Match found: ${location.title}');
        String matchType = titleMatch ? "title" : (descriptionMatch ? "description" : "type");
        print('[LOG SpecialSearch] ========= Match type: $matchType');
        
        results.add({
          'id': 'special_${location.title.toLowerCase().replaceAll(' ', '_')}',
          'title': location.title,
          'description': location.description,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'relativeLocation': location.relativeLocation,
          'type': location.type,
          'image': location.image,
          'source': 'special',
        });
      }
    }
    
    print('[LOG SpecialSearch] ========= Total special results: ${results.length}');
    return results;
  }
} 