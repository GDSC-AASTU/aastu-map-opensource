import 'dart:async';
import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/pages/discover/gebeta_maps_service.dart';
import 'package:aastu_map/pages/discover/places_search_service.dart';
import 'package:aastu_map/pages/discover/search_history_model.dart';
import 'package:aastu_map/pages/discover/search_history_service.dart';
import 'package:aastu_map/pages/full_map/full_map_page.dart';
import 'package:aastu_map/pages/places/place_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

class DiscoverPage extends StatefulWidget {
  final String? initialQuery;
  
  const DiscoverPage({this.initialQuery, Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Map<String, dynamic>> _placeResults = [];
  List<Map<String, dynamic>> _gebetaResults = [];
  
  Timer? _debounce;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // Set initial query if provided, otherwise use default 'aastu'
    final initialSearchTerm = widget.initialQuery ?? 'aastu';
    
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    
    // Focus the search field when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      
      // Perform initial search
      print('[LOG DiscoverPage] ========= Performing initial search for "$initialSearchTerm"');
      _performSearch(initialSearchTerm);
    });
    
    // Listen for changes to the search text
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }
  
  // Handle search text changes with debounce
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      print('[LOG DiscoverPage] ========= Search text changed: ${_searchController.text}');
      _performSearch(_searchController.text);
    });
  }
  
  // Perform the search across different sources
  Future<void> _performSearch(String query) async {
    print('[LOG DiscoverPage] ========= Performing search for: $query');
    
    if (query.trim().isEmpty) {
      print('[LOG DiscoverPage] ========= Empty query, clearing results');
      setState(() {
        _placeResults = [];
        _gebetaResults = [];
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Search places (Firebase + Special Locations)
      print('[LOG DiscoverPage] ========= Calling PlacesSearchService');
      final placeResults = await PlacesSearchService.searchPlaces(query);
      print('[LOG DiscoverPage] ========= Places search returned ${placeResults.length} results');
      
      // Search Gebeta Maps
      print('[LOG DiscoverPage] ========= Calling GebetaMapsService');
      final gebetaMapResults = await GebetaMapsService.searchPlaces(query);
      print('[LOG DiscoverPage] ========= Gebeta search returned ${gebetaMapResults.length} results');
      final formattedGebetaResults = GebetaMapsService.formatGebetaResults(gebetaMapResults);
      
      // Update state with results
      if (mounted) {
        print('[LOG DiscoverPage] ========= Updating state with results');
        setState(() {
          _placeResults = placeResults;
          _gebetaResults = formattedGebetaResults;
          _isLoading = false;
        });
      }
      
    } catch (e) {
      print('[LOG DiscoverPage] ========= Error during search: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Handle search submission
  Future<void> _onSearchSubmitted(String query) async {
    print('[LOG DiscoverPage] ========= Search submitted: $query');
    
    if (query.trim().isEmpty) return;
    
    // Add to search history
    print('[LOG DiscoverPage] ========= Adding to search history');
    await SearchHistoryService.addQuery(query);
    
    // Perform search
    await _performSearch(query);
  }
  
  // Open a place detail
  void _openPlaceDetail(Map<String, dynamic> place) {
    final source = place['source'];
    
    print('[LOG DiscoverPage] ========= Opening place: ${place['title']} from source: $source');
    
    if (source == 'firebase') {
      print('[LOG DiscoverPage] ========= Navigating to PlaceDetail page for Firebase place: ${place['id']}');
      // Use the proper PlaceDetail page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaceDetail(
            id: place['id'],
            place: place,
          ),
        ),
      );
    } else if (source == 'special') {
      print('[LOG DiscoverPage] ========= Navigating to Full Map page for special place with coordinates: ${place['latitude']}, ${place['longitude']}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullMapPage(
            initialLocation: LatLng(place['latitude'], place['longitude']),
            initialPlace: place,
          ),
        ),
      );
    }
  }
  
  // Open Gebeta Maps result
  void _openGebetaResult(Map<String, dynamic> result) {
    print('[LOG DiscoverPage] ========= Opening Gebeta result: ${result['title']}');
    
    double? lat, lng;
    
    // Handle new API response structure with 'lat' and 'lng'
    if (result['lat'] != null && result['lng'] != null) {
      lat = result['lat'] is double ? result['lat'] : double.tryParse(result['lat'].toString());
      lng = result['lng'] is double ? result['lng'] : double.tryParse(result['lng'].toString());
      print('[LOG DiscoverPage] ========= Coordinates found via lat/lng: $lat, $lng');
    }
    // Handle old API response structure with 'coordinates' array
    else if (result['coordinates'] != null && result['coordinates'] is List) {
      final List coordinates = result['coordinates'];
      if (coordinates.length == 2) {
        lat = coordinates[0] is double ? coordinates[0] : double.tryParse(coordinates[0].toString());
        lng = coordinates[1] is double ? coordinates[1] : double.tryParse(coordinates[1].toString());
        print('[LOG DiscoverPage] ========= Coordinates found via array: $lat, $lng');
      }
    }
    
    if (lat != null && lng != null) {
      final formattedResult = {
        'title': result['title'] ?? 'Unknown Location',
        'latitude': lat,
        'longitude': lng,
        'description': result['city'] != null 
            ? '${result['city']}, ${result['country'] ?? ''}'
            : result['type'] ?? 'Location',
        'source': 'gebeta',
        'type': result['type'] ?? 'location',
      };
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullMapPage(
            initialLocation: LatLng(lat!, lng!),
            initialPlace: formattedResult,
          ),
        ),
      );
    } else {
      print('[LOG DiscoverPage] ========= No coordinates found in result');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find coordinates for this location')),
      );
    }
  }
  
  // Clear search history
  void _clearSearchHistory() async {
    await SearchHistoryService.clearHistory();
    setState(() {});
  }
  
  // Build search history chips
  Widget _buildSearchHistoryChips() {
    final history = SearchHistoryService.getSearchHistory();
    
    if (history.isEmpty) {
      return Container();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: _clearSearchHistory,
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: history.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final item = history[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  label: Text(item.query),
                  onDeleted: () async {
                    await SearchHistoryService.removeQuery(item.query);
                    setState(() {});
                  },
                  deleteIcon: const Icon(Icons.close, size: 18),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
  
  // Build place result item
  Widget _buildPlaceResultItem(Map<String, dynamic> place) {
    final bool isSpecial = place['source'] == 'special';
    final String imageUrl = place['images'] != null && place['images'] is List && (place['images'] as List).isNotEmpty
        ? (place['images'] as List).first.toString()
        : place['image'] ?? '';
    
    return InkWell(
      onTap: () => _openPlaceDetail(place),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty 
                    ? imageUrl.startsWith('http')
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                Icon(isSpecial ? Icons.location_on : LineIcons.mapMarker, color: Colors.grey),
                          )
                        : Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                Icon(isSpecial ? Icons.location_on : LineIcons.mapMarker, color: Colors.grey),
                          )
                    : Icon(isSpecial ? Icons.location_on : LineIcons.mapMarker, color: Colors.grey),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place['title'] ?? 'Unknown Place',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSpecial
                        ? place['relativeLocation'] ?? ''
                        : place['blockNo'] != null 
                            ? 'Block ${place['blockNo']}' 
                            : place['description'] ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Icon to show source with chip for special locations
            isSpecial
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: AppColors.primary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'local',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
          ],
        ),
      ),
    );
  }
  
  // Build Gebeta result item
  Widget _buildGebetaResultItem(Map<String, dynamic> result) {
    final String subtitle = result['city'] != null 
        ? '${result['city']}, ${result['country'] ?? ''}'
        : result['type'] ?? 'Location';
        
    return InkWell(
      onTap: () => _openGebetaResult(result),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  LineIcons.mapMarked,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    result['title'] ?? 'Unknown Location',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Gebeta badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LineIcons.map,
                    color: Colors.orange,
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Gebeta',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasResults = _placeResults.isNotEmpty || _gebetaResults.isNotEmpty;
    final bool showHistory = _searchController.text.isEmpty;
    
    return WillPopScope(
      // Handle back button to ensure clean navigation back to home
      onWillPop: () async {
        // Clean up any resources if needed before popping
        return true;
      },
      child: Scaffold(
        // Ensure we're using a clean scaffold with no inherited elements
        extendBody: false,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Discover',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search for places, buildings...',
                  prefixIcon: const Icon(LineIcons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              // Keep the initial search results when clearing
                              final defaultSearch = widget.initialQuery ?? 'aastu';
                              _performSearch(defaultSearch);
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onSubmitted: _onSearchSubmitted,
                textInputAction: TextInputAction.search,
                autofocus: true,
              ),
            ),
            
            // Search History
            if (showHistory) _buildSearchHistoryChips(),
            
            // Loading Indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            
            // Results
            if (!_isLoading && hasResults)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Places Section
                    if (_placeResults.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Places',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ...(_placeResults.map((place) => _buildPlaceResultItem(place)).toList()),
                    ],
                    
                    // Gebeta Maps Section
                    if (_gebetaResults.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'From Gebeta Maps',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ...(_gebetaResults.map((result) => _buildGebetaResultItem(result)).toList()),
                    ],
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            
            // No Results
            if (!_isLoading && !hasResults && _searchController.text.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LineIcons.searchMinus,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found for "${_searchController.text}"',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 