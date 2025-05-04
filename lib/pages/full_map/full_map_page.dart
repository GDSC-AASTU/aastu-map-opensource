import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/pages/discover/special_location_model.dart';
import 'package:aastu_map/pages/places/place_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class FullMapPage extends StatefulWidget {
  final LatLng? initialLocation;
  final Map<String, dynamic>? initialPlace;

  const FullMapPage({
    Key? key,
    this.initialLocation,
    this.initialPlace,
  }) : super(key: key);

  @override
  State<FullMapPage> createState() => _FullMapPageState();
}

class _FullMapPageState extends State<FullMapPage> {
  final MapController _mapController = MapController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _places = [];
  List<Map<String, dynamic>> _specialPlaces = [];
  Map<String, dynamic>? _selectedPlace;
  bool _isSatelliteView = true;

  @override
  void initState() {
    super.initState();
    _loadSpecialLocations();
    _fetchPlaces();
    
    // Set initial place if provided
    if (widget.initialPlace != null) {
      setState(() {
        _selectedPlace = widget.initialPlace;
      });
      
      // Add a delay to ensure the map is loaded before centering
      Future.delayed(const Duration(milliseconds: 500), () {
        if (widget.initialLocation != null && _mapController.camera != null) {
          _mapController.move(widget.initialLocation!, 17.5);
        }
      });
    }
  }

  // Load special locations from our predefined list
  void _loadSpecialLocations() {
    setState(() {
      _specialPlaces = specialLocations.map((location) {
        return {
          'id': 'special_${location.title.toLowerCase().replaceAll(' ', '_')}',
          'title': location.title,
          'description': location.description,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'relativeLocation': location.relativeLocation,
          'type': location.type,
          'image': location.image,
          'source': 'special',
        };
      }).toList();
      
      print('[LOG FullMapPage] ========= Loaded ${_specialPlaces.length} special locations');
    });
  }

  // Fetch places from Firebase
  Future<void> _fetchPlaces() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('[LOG FullMapPage] ========= Fetching places from Firebase');
      final placesSnapshot = await FirebaseFirestore.instance.collection('places').get();
      
      final places = placesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['source'] = 'firebase';
        return data;
      }).where((place) {
        // Filter places that have latitude and longitude
        final hasLocation = place['latitude'] != null && place['longitude'] != null;
        if (!hasLocation) {
          print('[LOG FullMapPage] ========= Place missing location: ${place['title']}');
        }
        return hasLocation;
      }).toList();

      print('[LOG FullMapPage] ========= Found ${places.length} places with coordinates from Firebase');
      
      if (mounted) {
        setState(() {
          _places = places;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[LOG FullMapPage] ========= Error fetching places: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Open Google Maps with the selected location
  Future<void> _openGoogleMaps(double lat, double lng, String title) async {
    print('[LOG FullMapPage] ========= Opening Google Maps for: $title at $lat, $lng');
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final Uri uri = Uri.parse(url);
    
    print('[LOG FullMapPage] ========= Maps URL: $url');
    
    if (await canLaunchUrl(uri)) {
      print('[LOG FullMapPage] ========= Launching URL');
      await launchUrl(uri);
    } else {
      print('[LOG FullMapPage] ========= Could not launch URL');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch maps')),
        );
      }
    }
  }

  // Get marker icon based on place type
  IconData _getMarkerIcon(String type) {
    switch (type.toLowerCase()) {
      case 'library':
        return Icons.menu_book;
      case 'dormitory':
        return Icons.hotel;
      case 'sports':
        return Icons.sports_soccer;
      case 'cafeteria':
        return Icons.restaurant;
      case 'cafe':
        return Icons.coffee;
      case 'office':
        return Icons.business;
      default:
        return Icons.location_on;
    }
  }

  // Get marker color based on place source and type
  Color _getMarkerColor(String source, String type) {
    // Special places use type-based colors
    if (source == 'special') {
      switch (type.toLowerCase()) {
        case 'library':
          return Colors.blue;
        case 'dormitory':
          return Colors.purple;
        case 'sports':
          return Colors.green;
        case 'cafeteria':
        case 'cafe':
          return Colors.orange;
        case 'office':
          return Colors.brown;
        default:
          return AppColors.primary;
      }
    }
    
    // Firebase places use the primary app color
    return AppColors.primary;
  }

  // Get place subtitle based on place data
  String _getPlaceSubtitle(Map<String, dynamic> place) {
    // For Firebase places, use block number if available
    if (place['source'] == 'firebase' && place['blockNo'] != null) {
      return 'Block ${place["blockNo"]}';
    }
    
    // For special places, show the type
    if (place['source'] == 'special' && place['type'] != null) {
      return place['type'].toString().toUpperCase();
    }
    
    // Default to relative location or an empty string
    return place['relativeLocation'] ?? '';
  }
  
  // Get place image widget based on place data
  Widget _getPlaceImage(Map<String, dynamic> place) {
    // For Firebase places with images
    if (place['source'] == 'firebase' && place['images'] != null && 
        (place['images'] as List).isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          (place['images'] as List).first,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              _getMarkerIcon(place['type'] ?? ''), 
              size: 30, 
              color: Colors.grey.shade600,
            );
          },
        ),
      );
    }
    
    // For special places with asset images
    if (place['source'] == 'special' && place['image'] != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          place['image'],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              _getMarkerIcon(place['type'] ?? ''), 
              size: 30, 
              color: Colors.grey.shade600,
            );
          },
        ),
      );
    }
    
    // Default to icon based on type
    return Icon(
      _getMarkerIcon(place['type'] ?? ''), 
      size: 30, 
      color: Colors.grey.shade600,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Combine all places for display
    final allPlaces = [..._places, ..._specialPlaces];

    return Scaffold(
      // Set to hide bottom navigation and handle routing issues
      extendBody: true,
      extendBodyBehindAppBar: true,
      // Hide floating action button and bottom navigation
      floatingActionButton: null,
      floatingActionButtonLocation: null,
      bottomNavigationBar: null,
      primary: true, // Ensures this scaffold takes precedence
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Campus Map',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        // Custom back button
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Simply pop back to previous screen
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Toggle map view between satellite and standard
          IconButton(
            icon: Icon(_isSatelliteView ? Icons.map : Icons.satellite),
            onPressed: () {
              setState(() {
                _isSatelliteView = !_isSatelliteView;
              });
            },
            tooltip: _isSatelliteView ? 'Switch to Standard Map' : 'Switch to Satellite View',
          ),
          // Reload places
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPlaces,
            tooltip: 'Refresh Places',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialLocation ?? const LatLng(8.885239591746624, 38.81039712540425),
              initialZoom: 17.5,
              onTap: (_, __) {
                // Clear selection when tapping on the map (not on a marker)
                setState(() {
                  _selectedPlace = null;
                });
              },
              onMapReady: () {
                // If initial place and location are provided, center the map
                if (widget.initialLocation != null) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _mapController.move(widget.initialLocation!, 17.5);
                  });
                }
              },
            ),
            children: [
              // Map Tile Layer - Switch between satellite and standard view
              TileLayer(
                urlTemplate: _isSatelliteView
                    ? 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'  // Satellite
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',     // Standard
                userAgentPackageName: 'com.gdsc.aastu_map',
                additionalOptions: const {
                  'accessToken': '',
                  'id': 'mapbox.satellite',
                },
              ),
              
              // Place Markers
              MarkerLayer(
                markers: allPlaces.map((place) {
                  final double lat = place['latitude'] ?? 0.0;
                  final double lng = place['longitude'] ?? 0.0;
                  final String title = place['title'] ?? 'Unknown Place';
                  final String type = place['type'] ?? '';
                  final String source = place['source'] ?? 'firebase';
                  final bool isSelected = _selectedPlace != null && _selectedPlace!['id'] == place['id'];
                  final markerColor = _getMarkerColor(source, type);

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlace = place;
                        });
                        
                        // Enhanced animation for smoother zoom experience
                        // First move to current position at higher zoom level
                        final currentZoom = _mapController.camera.zoom;
                        final targetZoom = 18.5; // Higher zoom level for better detail
                        
                        // Start an animated sequence:
                        // 1. Quick slight zoom in with current center to avoid jarring movement
                        Future.delayed(const Duration(milliseconds: 50), () {
                          _mapController.move(
                            _mapController.camera.center,
                            currentZoom + 0.5,
                          );
                          
                          // 2. Then move to the target with full zoom after a small delay
                          Future.delayed(const Duration(milliseconds: 150), () {
                            _mapController.move(
                              LatLng(lat, lng),
                              targetZoom,
                            );
                          });
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(isSelected ? 0 : 4),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? markerColor
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: markerColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _getMarkerIcon(type),
                            color: isSelected 
                                ? Colors.white
                                : markerColor,
                            size: isSelected ? 24 : 20,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            
          // Selected Place Info Card
          if (_selectedPlace != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Place image or icon
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _getPlaceImage(_selectedPlace!),
                          ),
                          const SizedBox(width: 16),
                          
                          // Place details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedPlace!['title'] ?? 'Unknown Place',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getPlaceSubtitle(_selectedPlace!),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.pin_drop,
                                      size: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        _selectedPlace!['description'] ?? 
                                        _selectedPlace!['relativeLocation'] ?? 
                                        'No description',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Panorama 3D button (disabled)
                          OutlinedButton.icon(
                            onPressed: () {
                              // Show a snackbar indicating panorama view isn't available
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.white),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Panorama view for this place not available',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.grey[800],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: Duration(seconds: 3),
                                  action: SnackBarAction(
                                    label: 'OK',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    },
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.view_in_ar),
                            label: const Text('Panorama 3D'),
                          ),
                          
                          // View Details button - only for Firebase places
                          if (_selectedPlace!['source'] == 'firebase')
                            OutlinedButton(
                              onPressed: () {
                                if (mounted && context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => PlaceDetail(
                                        id: _selectedPlace!['id'],
                                        place: _selectedPlace!,
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('View Details'),
                            ),
                          
                          // Navigate button (open in Google Maps)
                          ElevatedButton.icon(
                            onPressed: () {
                              final double lat = _selectedPlace!['latitude'] ?? 0.0;
                              final double lng = _selectedPlace!['longitude'] ?? 0.0;
                              final String title = _selectedPlace!['title'] ?? 'Unknown Place';
                              _openGoogleMaps(lat, lng, title);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getMarkerColor(
                                _selectedPlace!['source'] ?? 'firebase', 
                                _selectedPlace!['type'] ?? '',
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.directions),
                            label: const Text('Navigate'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
          // My Location Button
          Positioned(
            bottom: _selectedPlace != null ? 140 : 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                // Center on AASTU coordinates with smooth animation
                final currentZoom = _mapController.camera.zoom;
                const aastu = LatLng(8.885239591746624, 38.81039712540425);
                
                // If we're zoomed in too close, first zoom out slightly to get context
                if (currentZoom > 18) {
                  Future.delayed(const Duration(milliseconds: 50), () {
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom - 1.0,
                    );
                    
                    // Then move to campus center
                    Future.delayed(const Duration(milliseconds: 150), () {
                      _mapController.move(aastu, 17.5);
                    });
                  });
                } else {
                  // If zoom is reasonable, just move directly
                  _mapController.move(aastu, 17.5);
                }
                
                // Clear any selected place
                setState(() {
                  _selectedPlace = null;
                });
              },
              child: const Icon(
                Icons.my_location,
                color: AppColors.primary,
              ),
            ),
          ),
          
          // Zoom controls
          Positioned(
            top: 100, // Moved down to avoid app bar
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    final targetZoom = currentZoom + 1.0;
                    
                    // Apply zoom with a slight staggered animation for smoother feel
                    Future.delayed(const Duration(milliseconds: 50), () {
                      _mapController.move(
                        _mapController.camera.center,
                        currentZoom + 0.5, // First half of the zoom
                      );
                      
                      // Then complete the zoom
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _mapController.move(
                          _mapController.camera.center,
                          targetZoom,
                        );
                      });
                    });
                  },
                  child: const Icon(
                    Icons.add,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    final targetZoom = currentZoom - 1.0;
                    
                    // Apply zoom out with a slight staggered animation for smoother feel
                    Future.delayed(const Duration(milliseconds: 50), () {
                      _mapController.move(
                        _mapController.camera.center,
                        currentZoom - 0.5, // First half of the zoom out
                      );
                      
                      // Then complete the zoom out
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _mapController.move(
                          _mapController.camera.center,
                          targetZoom,
                        );
                      });
                    });
                  },
                  child: const Icon(
                    Icons.remove,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 