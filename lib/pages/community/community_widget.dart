import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/pages/community/community_detail.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class CommunityWidget extends StatelessWidget {
  final String id;
  final Map<String, dynamic> clubData;

  const CommunityWidget({
    Key? key,
    required this.id,
    required this.clubData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityDetail(
                id: id,
                clubData: clubData,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Club Logo (Left side)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: clubData['logoImage'] != null && clubData['logoImage'].toString().isNotEmpty
                  ? Image.network(
                      clubData['logoImage'],
                      height: 140,
                      width: 140,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 140,
                          width: 140,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 140,
                          width: 140,
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              LineIcons.users,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 140,
                      width: 140,
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          LineIcons.users,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
            ),
            
            // Club Info (Right side)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top section with name and description
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Club Name
                        Text(
                          clubData['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Club Description
                        Text(
                          clubData['description'] ?? 'No description',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    // Bottom section with members count and button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Members Count
                        Row(
                          children: [
                            const Icon(
                              LineIcons.users,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${clubData['membersCount'] ?? 0} members',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        
                        // View Details Button
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommunityDetail(
                                  id: id,
                                  clubData: clubData,
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(0, 0),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
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
