import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/pages/community/navigate_location_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityDetail extends StatefulWidget {
  final String id;
  final Map<String, dynamic> clubData;

  const CommunityDetail({
    Key? key,
    required this.id,
    required this.clubData,
  }) : super(key: key);

  @override
  State<CommunityDetail> createState() => _CommunityDetailState();
}

class _CommunityDetailState extends State<CommunityDetail> {
  @override
  void initState() {
    super.initState();
    // Make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with background image, logo and title
            Stack(
              children: [
                // Background Image
                SizedBox(
                  height: 250,
                  width: screenWidth,
                  child: widget.clubData['backgroundImage'] != null && 
                        widget.clubData['backgroundImage'].toString().isNotEmpty
                      ? Image.network(
                          widget.clubData['backgroundImage'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.primary,
                            );
                          },
                        )
                      : Container(
                          color: AppColors.primary,
                        ),
                ),
                
                // Gradient overlay for better text visibility
                Container(
                  height: 250,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                
                // Club info
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      // Logo
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: widget.clubData['logoImage'] != null && 
                                        widget.clubData['logoImage'].toString().isNotEmpty
                            ? NetworkImage(widget.clubData['logoImage'])
                            : null,
                        child: widget.clubData['logoImage'] == null || 
                               widget.clubData['logoImage'].toString().isEmpty
                            ? Icon(
                                LineIcons.users,
                                size: 40,
                                color: Colors.grey[600],
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      
                      // Title and members count
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.clubData['title'] ?? 'Club Details',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3.0,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  LineIcons.users,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.clubData['membersCount'] ?? 0} members',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Description Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.clubData['description'] ?? 'No description available.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Horizontal image gallery
            if (_hasImages())
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      'Gallery',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: (widget.clubData['images'] as List<dynamic>).length,
                      itemBuilder: (context, index) {
                        final imageUrl = (widget.clubData['images'] as List<dynamic>)[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              height: 180,
                              width: 240,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  width: 240,
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            
            // Social Media Section
            if (_hasSocialMedia())
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Social Media',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildSocialMediaButtons(),
                  ],
                ),
              ),
              
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  bool _hasImages() {
    return widget.clubData['images'] != null && 
           (widget.clubData['images'] as List<dynamic>).isNotEmpty;
  }
  
  bool _hasSocialMedia() {
    return widget.clubData['socialMedia'] != null && 
           (widget.clubData['socialMedia'] as List<dynamic>).isNotEmpty;
  }
  
  List<Widget> _buildSocialMediaButtons() {
    final socialMediaLinks = (widget.clubData['socialMedia'] as List<dynamic>?) ?? [];
    final List<Widget> buttons = [];
    
    for (final link in socialMediaLinks) {
      if (link is String && link.isNotEmpty) {
        // Determine the platform from the link
        String platform = '';
        IconData icon = Icons.link;
        Color color = Colors.blue;
        
        if (link.contains('telegram') || link.contains('t.me')) {
          platform = 'Telegram';
          icon = LineIcons.telegram;
          color = const Color(0xFF0088cc);
        } else if (link.contains('instagram')) {
          platform = 'Instagram';
          icon = LineIcons.instagram;
          color = const Color(0xFFE1306C);
        } else if (link.contains('twitter') || link.contains('x.com')) {
          platform = 'Twitter';
          icon = LineIcons.twitter;
          color = const Color(0xFF1DA1F2);
        } else if (link.contains('facebook')) {
          platform = 'Facebook';
          icon = LineIcons.facebook;
          color = const Color(0xFF1877F2);
        } else if (link.contains('linkedin')) {
          platform = 'LinkedIn';
          icon = LineIcons.linkedin;
          color = const Color(0xFF0077B5);
        } else if (link.contains('youtube')) {
          platform = 'YouTube';
          icon = LineIcons.youtube;
          color = const Color(0xFFFF0000);
        } else if (link.contains('github')) {
          platform = 'GitHub';
          icon = LineIcons.github;
          color = const Color(0xFF333333);
        } else if (link.contains('discord')) {
          platform = 'Discord';
          icon = LineIcons.discord;
          color = const Color(0xFF7289DA);
        } else {
          platform = 'Website';
          icon = LineIcons.globe;
          color = Colors.blue;
        }
        
        buttons.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () => _launchUrl(link),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        platform,
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: color, size: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return buttons;
  }
  
  VoidCallback _getPrimaryAction() {
    // Check for primary social media (Telegram first, then others)
    final socialMediaLinks = (widget.clubData['socialMedia'] as List<dynamic>?) ?? [];
    
    String? primaryLink;
    for (final link in socialMediaLinks) {
      if (link is String && link.isNotEmpty) {
        if (link.contains('telegram') || link.contains('t.me')) {
          primaryLink = link;
          break;
        } else if (primaryLink == null) {
          primaryLink = link;
        }
      }
    }
    
    return () {
      if (primaryLink != null) {
        _launchUrl(primaryLink);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No contact information available')),
        );
      }
    };
  }
  
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }
  
  @override
  void dispose() {
    // Reset system UI when leaving the page
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
    );
    super.dispose();
  }
}
