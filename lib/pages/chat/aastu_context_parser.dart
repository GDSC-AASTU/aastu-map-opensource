import 'package:flutter/services.dart';
import 'package:aastu_map/pages/chat/chat_message_model.dart';

class AastuContextParser {
  static String? _contextData;
  static final Map<String, MapLocation> _locations = {};
  static final Map<String, LinkPreview> _links = {};
  
  static Future<void> initialize() async {
    if (_contextData != null) {
      print('[LOG AastuContextParser] ========= Context already loaded');
      return;
    }
    
    try {
      print('[LOG AastuContextParser] ========= Loading context data');
      _contextData = await rootBundle.loadString('assets/data/aastu_llms.txt');
      print('[LOG AastuContextParser] ========= Context loaded: ${_contextData!.length} characters');
      
      // Parse locations and links
      _parseLocations();
      _parseLinks();
      
    } catch (e) {
      print('[LOG AastuContextParser] ========= Error loading context: $e');
      _contextData = null;
    }
  }
  
  static String? get contextData => _contextData;
  
  static void _parseLocations() {
    if (_contextData == null) return;
    
    print('[LOG AastuContextParser] ========= Parsing location data');
    final locationRegex = RegExp(r'(.*?):\s*(\d+\.\d+),\s*(\d+\.\d+)');
    
    try {
      final specialLocationsSection = _contextData!.split('Special Locations (Title, Latitude, Longitude):').last.split('Official Website Important Pages').first;
      
      final matches = locationRegex.allMatches(specialLocationsSection);
      for (final match in matches) {
        try {
          final title = match.group(1)?.trim() ?? '';
          final latitude = double.parse(match.group(2) ?? '0');
          final longitude = double.parse(match.group(3) ?? '0');
          
          if (title.isNotEmpty && latitude != 0 && longitude != 0) {
            _locations[title.toLowerCase()] = MapLocation(
              title: title,
              latitude: latitude,
              longitude: longitude,
            );
          }
        } catch (e) {
          print('[LOG AastuContextParser] ========= Error parsing location: ${match.group(0)}, error: $e');
        }
      }
      
      print('[LOG AastuContextParser] ========= Parsed ${_locations.length} locations');
    } catch (e) {
      print('[LOG AastuContextParser] ========= Error parsing locations section: $e');
    }
  }
  
  static void _parseLinks() {
    if (_contextData == null) return;
    
    print('[LOG AastuContextParser] ========= Parsing links data');
    
    try {
      final linksSection = _contextData!.split('Official Website Important Pages').last;
      final linkRegex = RegExp(r'(.*?)\s*-\s*(https:\/\/www\.aastu\.edu\.et\/[^\s]*)');
      
      final matches = linkRegex.allMatches(linksSection);
      for (final match in matches) {
        try {
          final title = match.group(1)?.trim() ?? '';
          final url = match.group(2)?.trim() ?? '';
          
          if (title.isNotEmpty && url.isNotEmpty) {
            final linkKey = title.toLowerCase();
            _links[linkKey] = LinkPreview(
              title: title,
              url: url,
            );
            
            // Also add keywords as keys for better matching
            final keywords = title.toLowerCase().split(' ');
            for (final keyword in keywords) {
              if (keyword.length > 4) { // Only use meaningful keywords
                _links[keyword] = LinkPreview(
                  title: title,
                  url: url,
                );
              }
            }
          }
        } catch (e) {
          print('[LOG AastuContextParser] ========= Error parsing link: ${match.group(0)}, error: $e');
        }
      }
      
      print('[LOG AastuContextParser] ========= Parsed link entries for ${_links.length} keywords');
    } catch (e) {
      print('[LOG AastuContextParser] ========= Error parsing links section: $e');
    }
  }
  
  // Find a location by name (exact or partial match)
  static MapLocation? findLocation(String query) {
    if (query.isEmpty) return null;
    
    final lowerQuery = query.toLowerCase();
    print('[LOG AastuContextParser] ========= Searching for location in: $lowerQuery');
    
    // First try explicit latitude/longitude format: "latitude X, longitude Y"
    final latLongRegex = RegExp(r'latitude\s+(\d+\.\d+)\s*,?\s*longitude\s+(\d+\.\d+)', caseSensitive: false);
    final latLongMatch = latLongRegex.firstMatch(lowerQuery);
    
    if (latLongMatch != null) {
      try {
        final lat = double.parse(latLongMatch.group(1) ?? '0');
        final lng = double.parse(latLongMatch.group(2) ?? '0');
        
        print('[LOG AastuContextParser] ========= Found coordinates in lat/long format: $lat, $lng');
        return _createLocationFromCoordinates(lowerQuery, latLongMatch, lat, lng);
      } catch (e) {
        print('[LOG AastuContextParser] ========= Error parsing lat/long format: $e');
      }
    }
    
    // If not found, try direct coordinate format: "X, Y"
    final coordRegex = RegExp(r'(\d+\.\d+)\s*,\s*(\d+\.\d+)');
    final coordMatches = coordRegex.allMatches(lowerQuery);
    
    if (coordMatches.isNotEmpty) {
      final coordMatch = coordMatches.first; // Use the first coordinates found
      try {
        final lat = double.parse(coordMatch.group(1) ?? '0');
        final lng = double.parse(coordMatch.group(2) ?? '0');
        
        print('[LOG AastuContextParser] ========= Found coordinates in direct format: $lat, $lng');
        return _createLocationFromCoordinates(lowerQuery, coordMatch, lat, lng);
      } catch (e) {
        print('[LOG AastuContextParser] ========= Error parsing coordinates: $e');
      }
    }
    
    // No valid coordinates found
    return null;
  }
  
  // Helper method to create a location from coordinates
  static MapLocation? _createLocationFromCoordinates(String lowerQuery, RegExpMatch match, double lat, double lng) {
    // Validate coordinates are in a reasonable range for AASTU and nearby area
    // Use a more generous range to accommodate all possible AASTU locations
    if (lat >= 8.88 && lat <= 8.90 && lng >= 38.80 && lng <= 38.82) {
      // Find the closest named location to these coordinates
      MapLocation? closestLocation;
      double minDistance = double.infinity;
      
      for (final location in _locations.values) {
        final distance = _calculateDistance(lat, lng, location.latitude, location.longitude);
        if (distance < minDistance) {
          minDistance = distance;
          closestLocation = location;
        }
      }
      
      if (closestLocation != null && minDistance < 0.0005) { // Very close match (within ~50m)
        print('[LOG AastuContextParser] ========= Found exact location match: ${closestLocation.title}');
        return closestLocation;
      } else {
        // If no named location is very close, create a custom location
        String locationName = "AASTU Location";
        
        // Try to extract a name from nearby text
        final beforeText = lowerQuery.substring(0, match.start).trim();
        final lastSentenceStart = beforeText.lastIndexOf('. ');
        final textToSearch = lastSentenceStart != -1 
            ? beforeText.substring(lastSentenceStart + 2) 
            : beforeText;
        
        // Look for common location identifiers
        final locationIdentifiers = ['the ', 'aastu ', 'block ', 'building ', 'office ', 'library ', 'lab ', 'dorm'];
        
        for (final identifier in locationIdentifiers) {
          final identifierPos = textToSearch.lastIndexOf(identifier);
          if (identifierPos != -1) {
            final endPos = textToSearch.indexOf(' is', identifierPos);
            final extractedName = endPos != -1 
                ? textToSearch.substring(identifierPos, endPos).trim() 
                : textToSearch.substring(identifierPos).trim();
            
            if (extractedName.length > 3) {
              // Format the name properly with capitalization
              locationName = extractedName.split(" ")
                  .map((word) => word.isNotEmpty 
                      ? word[0].toUpperCase() + word.substring(1) 
                      : '')
                  .join(" ");
              break;
            }
          }
        }
        
        print('[LOG AastuContextParser] ========= Created custom location: $locationName');
        return MapLocation(
          title: locationName,
          latitude: lat,
          longitude: lng,
        );
      }
    } else {
      print('[LOG AastuContextParser] ========= Coordinates outside of AASTU range: $lat, $lng');
      return null;
    }
  }
  
  // Helper to calculate rough distance between coordinates (in degrees)
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return ((lat1 - lat2) * (lat1 - lat2)) + ((lon1 - lon2) * (lon1 - lon2));
  }
  
  // Find relevant links based on keywords in the message
  static List<LinkPreview> findRelevantLinks(String content) {
    if (content.isEmpty) return [];
    
    final lowerContent = content.toLowerCase();
    final Set<LinkPreview> relevantLinks = {};
    
    // Extract explicit URLs first
    final urlRegex = RegExp("https?://(www\\.)?aastu\\.edu\\.et/[^\\s)\"']+");
    final urlMatches = urlRegex.allMatches(content);
    
    for (final match in urlMatches) {
      final urlRaw = match.group(0) ?? '';
      // Clean up the URL
      final url = urlRaw.trim().replaceAll(RegExp("[\\s)\"']+\$"), '');
      
      if (url.isNotEmpty) {
        // Look for a matching link in our database
        LinkPreview? linkPreview;
        
        // Find existing link preview
        for (final link in _links.values) {
          if (url.contains(link.url) || link.url.contains(url)) {
            linkPreview = link;
            break;
          }
        }
        
        // Create new link preview if not found
        if (linkPreview == null) {
          String title = 'AASTU Website';
          
          if (url.contains('/blog/')) {
            title = 'AASTU Blog';
          } else if (url.contains('/research/')) {
            title = 'AASTU Research';
          } else if (url.contains('/registrar/')) {
            title = 'AASTU Registrar';
          }
          
          linkPreview = LinkPreview(
            title: title,
            url: url,
          );
        }
        
        relevantLinks.add(linkPreview);
        print('[LOG AastuContextParser] ========= Found explicit URL: $url');
      }
    }
    
    // If we already found explicit URLs, don't look for keyword matches
    if (relevantLinks.isNotEmpty) {
      return relevantLinks.toList();
    }
    
    // List of keywords to ignore (too common or not specific enough)
    final ignoreKeywords = [
      'aastu', 'addis', 'ababa', 'science', 'technology', 'university',
      'hello', 'welcome', 'today', 'information', 'assist', 'help'
    ];
    
    // List of strong topic keywords that indicate specific resources
    final strongKeywords = {
      'library': 'AASTU Library related Info',
      'research': 'Research Directorate',
      'registrar': 'AASTU Registrar and Alumni Office',
      'alumni': 'AASTU Registrar and Alumni Office', 
      'ict': 'Information Communication Technology (ICT) Directorate',
      'hungary': 'Hungary Scholarship Program',
      'scholarship': 'Hungary Scholarship Program',
      'humanities': 'College of Social Science and Humanities',
      'social science': 'College of Social Science and Humanities',
      'announcement': 'Announcements',
      'blog': 'Blog'
    };
    
    // Check for strong topic matches first
    for (final entry in strongKeywords.entries) {
      final keyword = entry.key;
      final linkTitle = entry.value;
      
      // Check if the keyword is in the content
      if (lowerContent.contains(keyword)) {
        // Find the corresponding link preview
        for (final link in _links.values) {
          if (link.title == linkTitle) {
            relevantLinks.add(link);
            print('[LOG AastuContextParser] ========= Found strong keyword match: $keyword -> ${link.title}');
            // Only return the most relevant link
            break;
          }
        }
        
        // If we found a strong match, return it
        if (relevantLinks.isNotEmpty) {
          break;
        }
      }
    }
    
    // If strong keyword matches were found, return them
    if (relevantLinks.isNotEmpty) {
      return relevantLinks.toList();
    }
    
    // Otherwise, look for keyword-based matches, but be more selective
    for (final entry in _links.entries) {
      final keyword = entry.key;
      
      // Skip if keyword is in the ignore list or too short
      if (keyword.length < 5 || ignoreKeywords.contains(keyword)) {
        continue;
      }
      
      // Check if this is a significant keyword in the content
      // It must be a specific term, not just part of the university name
      if (lowerContent.contains(keyword)) {
        // Extra verification: make sure it's a meaningful match by checking context
        // Count how many times the keyword appears in the response
        final matches = RegExp('\\b$keyword\\b').allMatches(lowerContent).length;
        
        // Ensure the keyword is mentioned multiple times or is a significant part of the response
        if (matches > 1 || lowerContent.contains('about $keyword') || 
            lowerContent.contains('$keyword is') || lowerContent.contains('$keyword are') ||
            lowerContent.contains('$keyword information') || lowerContent.contains('$keyword resources')) {
          
          relevantLinks.add(entry.value);
          print('[LOG AastuContextParser] ========= Found significant keyword match: $keyword -> ${entry.value.title}');
          // Only return one link to avoid cluttering the chat
          break;
        } else {
          print('[LOG AastuContextParser] ========= Keyword found but not significant enough: $keyword');
        }
      }
    }
    
    print('[LOG AastuContextParser] ========= Found ${relevantLinks.length} relevant links');
    return relevantLinks.toList();
  }
} 