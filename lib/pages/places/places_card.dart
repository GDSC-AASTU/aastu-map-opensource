import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:aastu_map/core/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlaceCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> place;
  final String? img;
  final String? title;
  final String? location;
  final String? building;
  final VoidCallback? onPressed;
  final VoidCallback? onDelete;

  const PlaceCard({
    Key? key,
    required this.id,
    required this.place,
    this.img,
    this.title,
    this.location,
    this.building,
    this.onPressed,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use place data if available, otherwise use individual parameters
    final String title = place['title'] ?? place['name'] ?? this.title ?? 'No Title';
    final String description = place['description'] ?? 'No Description';
    final String building = place['blockNo'] ?? this.building ?? 'N/A';
    
    // Get the first image from the images array if available
    final List<dynamic> images = place['images'] ?? [];
    final String imagePath = images.isNotEmpty 
        ? images[0] 
        : (img ?? 'assets/library.jpg');

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image at the top
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: imagePath.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: imagePath,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            LineIcons.image,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      imagePath,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              LineIcons.image,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Content at the bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Location and Building in one row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Description with icon (left aligned)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              LineIcons.mapMarker,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Building with icon (right aligned)
                      if (building.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              LineIcons.building,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 2),
                            Text(
                              building,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}