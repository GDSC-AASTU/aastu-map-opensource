import 'package:aastu_map/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SuggestLocationPage extends StatefulWidget {
  const SuggestLocationPage({Key? key}) : super(key: key);

  @override
  State<SuggestLocationPage> createState() => _SuggestLocationPageState();
}

class _SuggestLocationPageState extends State<SuggestLocationPage> {
  final _formKey = GlobalKey<FormState>();
  final _locationNameController = TextEditingController();
  final _locationDescriptionController = TextEditingController();
  final _locationTypeController = TextEditingController();
  final _floorController = TextEditingController();
  bool _isSubmitting = false;
  
  // Location data
  LatLng? _selectedLocation;
  final LatLng _aastuCenter = const LatLng(8.8977, 38.7665); // AASTU approximate coordinates
  
  // Create a Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _locationNameController.dispose();
    _locationDescriptionController.dispose();
    _locationTypeController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  Future<void> _submitSuggestion() async {
    if (_formKey.currentState!.validate()) {
      // Check if location is selected
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please pick a location on the map'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Get current user information
        final User? currentUser = _auth.currentUser;
        final String userId = currentUser?.uid ?? 'anonymous';
        final String userEmail = currentUser?.email ?? 'anonymous';
        
        // Create a document to upload to Firestore
        final Map<String, dynamic> suggestionData = {
          'locationName': _locationNameController.text.trim(),
          'locationType': _locationTypeController.text.trim(),
          'description': _locationDescriptionController.text.trim(),
          'floor': _floorController.text.trim(),
          'coordinates': GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
          'userId': userId,
          'userEmail': userEmail,
          'status': 'pending', // pending, approved, rejected
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        // Upload to Firestore
        await _firestore.collection('suggestions').add(suggestionData);
        
        print('[LOG SuggestLocation] ========= Location suggestion uploaded to Firestore successfully');
        
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you! Your location suggestion has been submitted.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear form
          _locationNameController.clear();
          _locationDescriptionController.clear();
          _locationTypeController.clear();
          _floorController.clear();
          setState(() {
            _selectedLocation = null;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit suggestion: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        
        print('[LOG SuggestLocation] ========= Error submitting location suggestion: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          "Suggest a Location",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  child: const Icon(
                    LineIcons.mapMarker,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Help us improve AASTU Map by suggesting a new location that should be added to the map.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _locationNameController,
                  decoration: InputDecoration(
                    labelText: 'Location Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.place),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationTypeController,
                  decoration: InputDecoration(
                    labelText: 'Location Type',
                    hintText: 'e.g., Classroom, Lab, Office, etc.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please specify the location type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _floorController,
                  decoration: InputDecoration(
                    labelText: 'Floor Number',
                    hintText: 'e.g., 1, 2, Ground Floor, etc.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.layers),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Provide details about the location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Select Location on Map',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Tap on the map to select the exact location',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 250,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _aastuCenter,
                              zoom: 17,
                            ),
                            markers: _selectedLocation != null
                                ? {
                                    Marker(
                                      markerId: const MarkerId('selectedLocation'),
                                      position: _selectedLocation!,
                                      icon: BitmapDescriptor.defaultMarkerWithHue(
                                          BitmapDescriptor.hueRed),
                                    )
                                  }
                                : {},
                            onTap: (LatLng position) {
                              setState(() {
                                _selectedLocation = position;
                                print('[LOG SuggestLocation] ========= Selected location: ${position.latitude}, ${position.longitude}');
                              });
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            mapType: MapType.normal,
                            zoomControlsEnabled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedLocation != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Selected coordinates: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitSuggestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit Suggestion',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Note: Your suggestions will be reviewed by our team before being added to the map.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 