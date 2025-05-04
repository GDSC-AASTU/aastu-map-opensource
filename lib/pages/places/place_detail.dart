import 'dart:developer';
import 'dart:ui';
import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/pages/full_map/full_map_page.dart';
import 'package:aastu_map/pages/places/panorama_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:line_icons/line_icons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class PlaceDetail extends StatefulWidget {
  final String id;
  final Map<String, dynamic> place;

  const PlaceDetail({
    Key? key,
    required this.id,
    required this.place,
  }) : super(key: key);

  @override
  State<PlaceDetail> createState() => _PlaceDetailState();
}

class _PlaceDetailState extends State<PlaceDetail> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<String> _images = [];
  double? _distanceInMeters;

  @override
  void initState() {
    super.initState();
    _images = List<String>.from(widget.place['images'] ?? []);
    if (_images.isEmpty) {
      _images.add('assets/library.jpg');
    }

    // Make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Calculate the distance
    _calculateDistance();
  }

  Future<void> _calculateDistance() async {
    try {
      // Get the user's current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      log('Current position: $position');

      log(widget.place['location'].toString());

      // Get the destination coordinates

      final double destinationLat = widget.place['location']['lat'] as double;
      final double destinationLng = widget.place['location']['lng'] as double;

      log('Destination coordinates: $destinationLat, $destinationLng');

      // Calculate the distance
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        destinationLat,
        destinationLng,
      );

      // Update the state
      setState(() {
        _distanceInMeters = distance;
      });
    } catch (e) {
      // Handle errors (e.g., permissions denied)
      print('Error calculating distance: $e');
    }
  }

  Future<void> _launchMaps() async {
    final lat = widget.place['location']['lat'] as double;
    final lng = widget.place['location']['lng'] as double;
    final name = widget.place['title'] ?? 'Location';

    log('place details: ${widget.place.toString()}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullMapPage(
          initialLocation: LatLng(lat, lng),
          initialPlace: {
            'id': 'location_${name.toLowerCase().replaceAll(' ', '_')}',
            'title': name,
            'latitude': lat,
            'longitude': lng,
            'type': 'office', // Default type
            'source': 'special',
          },
        ),
      ),
    );
  }

  List<Widget> _buildServiceChips() {
    List<Widget> chips = [];

    // Use services array if available
    List<dynamic> services = widget.place['services'] ?? [];
    for (var service in services) {
      if (service is String && service.isNotEmpty) {
        // Map service names to icons
        IconData? icon;
        if (service.toLowerCase().contains('wifi')) {
          icon = Icons.wifi;
        } else if (service.toLowerCase().contains('book')) {
          icon = Icons.book;
        } else if (service.toLowerCase().contains('24/7') ||
            service.toLowerCase().contains('hour')) {
          icon = Icons.access_time;
        } else if (service.toLowerCase().contains('parking')) {
          icon = Icons.local_parking;
        } else if (service.toLowerCase().contains('coffee') ||
            service.toLowerCase().contains('food')) {
          icon = Icons.restaurant;
        } else {
          icon = Icons.check_circle_outline;
        }

        chips.add(_buildServiceChip(service, icon));
      }
    }

    // Add fallback services if none found in the array
    if (chips.isEmpty) {
      // Legacy support for old data model
      if (widget.place['freeWifi'] == true) {
        chips.add(_buildServiceChip('Free Wifi', Icons.wifi));
      }

      if (widget.place['hasBooks'] == true) {
        chips.add(_buildServiceChip('1000+ Books', Icons.book));
      }

      if (widget.place['openHours'] != null) {
        chips.add(_buildServiceChip('24/7', Icons.access_time));
      }

      if (widget.place['capacity'] != null) {
        chips.add(_buildServiceChip(
            '${widget.place['capacity']} people', Icons.people));
      }
    }

    return chips;
  }

  Widget _buildServiceChip(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageView(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primary,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                LineIcons.image,
                size: 40,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                LineIcons.image,
                size: 40,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Fixed dimensions
    final imageHeight = screenHeight * 0.45;
    final bottomSheetHeight = screenHeight * 0.6;
    final bottomSheetTop = screenHeight - bottomSheetHeight;

    return WillPopScope(
      // Handle back button to ensure clean navigation
      onWillPop: () async {
        // Reset system UI when leaving the page
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
        );
        return true;
      },
      child: Scaffold(
        // Ensure we're using a clean scaffold without inheriting elements
        extendBody: false,
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            widget.place['title'] ?? 'Place Details',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3.0,
                  color: Color.fromARGB(128, 0, 0, 0),
                ),
              ],
            ),
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Stack(
          children: [
            // Full-sized background color
            Container(
              height: screenHeight,
              width: screenWidth,
              color: Colors.white,
            ),

            // Image slider with fixed height
            SizedBox(
              height: imageHeight,
              width: screenWidth,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PanoramaView(
                            imageUrl: _images[index],
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImageView(_images[index]),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicator dots
            if (_images.length > 1)
              Positioned(
                bottom: bottomSheetHeight - 20,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _images.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                      dotColor: Colors.white.withOpacity(0.5),
                      activeDotColor: Colors.white,
                    ),
                  ),
                ),
              ),

            // Image counter
            if (_images.length > 1)
              Positioned(
                top: 80,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentPage + 1}/${_images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Fixed bottom sheet
            Positioned(
              top: bottomSheetTop,
              height: bottomSheetHeight,
              width: screenWidth,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Rounded handle for bottom sheet
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // Scrollable content
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                widget.place['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // Block information
                              if (widget.place['blockNo'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LineIcons.building,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${widget.place['blockNo']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      LineIcons.mapMarker,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _distanceInMeters != null
                                          ? _distanceInMeters! < 1000
                                              ? '${_distanceInMeters!.toStringAsFixed(0)} m from you'
                                              : '${(_distanceInMeters! / 1000).toStringAsFixed(2)} km from you'
                                          : 'Calculating distance...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Services chips
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _buildServiceChips(),
                              ),

                              const SizedBox(height: 16),

                              // Description section
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.place['description'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Map button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton.icon(
                                  onPressed: _launchMaps,
                                  icon: const Icon(Icons.map),
                                  label: const Text(
                                    'VIEW ON MAP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  @override
  void dispose() {
    _pageController.dispose();
    // Reset already handled in WillPopScope
    super.dispose();
  }
}
