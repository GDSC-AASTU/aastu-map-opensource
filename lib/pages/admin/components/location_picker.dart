import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/data/models/place_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class LocationPicker extends StatefulWidget {
  final GeoLocation? initialLocation;
  final Function(GeoLocation) onLocationSelected;

  const LocationPicker({
    Key? key,
    this.initialLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  bool _mapInitialized = false;
  String? _errorMessage;
  
  // Default to AASTU location (approximately)
  static const _defaultLocation = LatLng(8.9806, 38.7578);
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = LatLng(
        widget.initialLocation!.lat,
        widget.initialLocation!.lng,
      );
      _updateMarker();
    }
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _updateMarker() {
    if (_selectedLocation != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: _selectedLocation!,
            draggable: true,
            onDragEnd: (newPosition) {
              setState(() {
                _selectedLocation = newPosition;
                _notifyLocationChange();
              });
            },
          ),
        };
      });
    }
  }

  void _notifyLocationChange() {
    if (_selectedLocation != null) {
      widget.onLocationSelected(
        GeoLocation(
          lat: _selectedLocation!.latitude,
          lng: _selectedLocation!.longitude,
        ),
      );
    }
  }
  
  Future<void> _onMapCreated(GoogleMapController controller) async {
    try {
      if (!_controller.isCompleted) {
        _controller.complete(controller);
      }
      _mapController = controller;
      
      setState(() {
        _mapInitialized = true;
        _errorMessage = null;
      });
      
      // Set custom map style if needed
      // final String style = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
      // await controller.setMapStyle(style);
    } catch (e) {
      setState(() {
        _errorMessage = "Error initializing map: $e";
      });
      print("Error initializing map: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _errorMessage != null 
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation ?? _defaultLocation,
                  zoom: 16,
                ),
                markers: _markers,
                onMapCreated: _onMapCreated,
                onTap: (position) {
                  setState(() {
                    _selectedLocation = position;
                    _updateMarker();
                    _notifyLocationChange();
                  });
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: true,
              ),
          ),
        ),
        const SizedBox(height: 8),
        if (_errorMessage == null) ...[
          if (_selectedLocation != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Selected: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Tap on the map to select a location',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ],
    );
  }
} 