import 'package:aastu_map/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigateLocationButton extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String address;

  const NavigateLocationButton({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _launchMapNavigation,
      icon: const Icon(Icons.map_outlined),
      label: const Text('VIEW ON MAP'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _launchMapNavigation() async {
    // Google Maps URL
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final googleUri = Uri.parse(googleMapsUrl);
    
    if (await canLaunchUrl(googleUri)) {
      await launchUrl(googleUri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to Apple Maps on iOS or another map app on Android
      final fallbackUrl = 'geo:$latitude,$longitude?q=${Uri.encodeComponent(address)}';
      final fallbackUri = Uri.parse(fallbackUrl);
      
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri);
      }
    }
  }
}
