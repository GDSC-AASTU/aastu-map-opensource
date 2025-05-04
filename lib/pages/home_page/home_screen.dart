import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/pages/home_page/Catagory_model.dart';
import 'package:aastu_map/pages/home_page/place_highlight_model.dart';
import 'package:aastu_map/pages/home_page/place_highlight_widget.dart';
import 'package:aastu_map/pages/home_page/search_bar.dart';
import 'package:aastu_map/pages/discover/discover_page.dart';
import 'package:aastu_map/pages/full_map/full_map_page.dart';
import 'package:aastu_map/pages/places/place_detail.dart';
import 'package:aastu_map/pages/community/community_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController controller = TextEditingController();
  int selected = -1;
  bool filter_selected = false;
  
  // Get current user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  void _onCategoryTap(int index) {
    // Navigate to discover page with the selected category as search text
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DiscoverPage(initialQuery: catagory[index].name),
      ),
    );
  }

  // Get greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final EdgeInsets padding = MediaQuery.of(context).viewPadding;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom App Bar with Greeting
              Container(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  // Shadow removed as requested
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Greeting and User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black38,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          currentUser?.isAnonymous == true
                            ? const Text(
                                'Welcome to AASTU',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              )
                            : StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser?.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Text(
                                      'Hello there',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primary,
                                      ),
                                    );
                                  }
                                  
                                  String userName = 'User';
                                  if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                                    final userData = snapshot.data!.data() as Map<String, dynamic>?;
                                    if (userData != null) {
                                      // Using the correct field name 'firstname'
                                      userName = userData['firstname'] ?? 
                                                userData['name']?.toString().split(' ').first ?? 
                                                'User';
                                      
                                      // Capitalize the first letter of the name
                                      if (userName.isNotEmpty) {
                                        userName = userName[0].toUpperCase() + userName.substring(1);
                                      }
                                    }
                                  }
                                  
                                  return Text(
                                    'Hello, $userName',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  );
                                },
                              ),
                          const SizedBox(height: 2),
                          currentUser?.isAnonymous == true
                            ? const Text(
                                'Discover the campus with ease',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : const Text(
                                'Let\'s explore AASTU campus today',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                        ],
                      ),
                    ),
                    
                    // Avatar/Profile Icon
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: currentUser?.photoURL != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: Image.network(
                                  currentUser!.photoURL!,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Ionicons.person,
                                      size: 30,
                                      color: AppColors.primary,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Ionicons.person,
                                size: 30,
                                color: AppColors.primary,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 5, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Section
                    Align(
                      alignment: Alignment.topCenter,
                      child: SearchBAR(
                        controller: controller,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Map Section - Card with Image
                    Container(
                      height: height * 0.28,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to full map page using Navigator
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullMapPage(),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Map Image with animation
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: _AnimatedMapBackground(),
                              ),
                              // Darkening Overlay
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                              ),
                              // Text at bottom
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.explore,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Explore Map',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 3.0,
                                            color: Colors.black.withOpacity(0.5),
                                            offset: const Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Categories Section
                    Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
                      height: height * 0.08,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: catagory.length,
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () => _onCategoryTap(index),
                          child: IntrinsicWidth(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  right: 10.0, top: 2.0, bottom: 2.0, left: 5.0),
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(58.5),
                                color: AppColors.white,
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 15.0,
                                  right: 15,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      catagory[index].icon,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 5.0),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          catagory[index].name,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4.0),
                                  
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Popular Places Title
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Text(
                        'Popular Places',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Fetch and display popular places from Firebase
                    SizedBox(
                      height: height * 0.31,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('places')
                            .orderBy('createdAt', descending: true)
                            .limit(5)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError) {
                            return const Center(child: Text('Error loading places'));
                          }
                          
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('No places found'));
                          }
                          
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final placeData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                              final String placeId = snapshot.data!.docs[index].id;
                              
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    print("[LOG PlaceDetail] ========= Navigating to place detail: $placeId");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PlaceDetail(
                                          id: placeId,
                                          place: placeData,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 280,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Image at the top
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                          child: placeData['images'] != null && (placeData['images'] as List).isNotEmpty
                                              ? Image.network(
                                                  (placeData['images'] as List).first.toString(),
                                                  height: 140,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      height: 140,
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
                                                )
                                              : Container(
                                                  height: 140,
                                                  color: Colors.grey[300],
                                                  child: Center(
                                                    child: Icon(
                                                      LineIcons.image,
                                                      size: 40,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
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
                                                placeData['title'] ?? 'No Title',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              
                                              const SizedBox(height: 8),
                                              
                                              // Block number and services
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  // Location with icon (left aligned)
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          LineIcons.mapMarker,
                                                          size: 12,
                                                          color: AppColors.primary,
                                                        ),
                                                        const SizedBox(width: 2),
                                                        Expanded(
                                                          child: Text(
                                                            placeData['description'] ?? 'No description',
                                                            style: const TextStyle(
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
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        LineIcons.building,
                                                        size: 12,
                                                        color: AppColors.primary,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        placeData['blockNo'] ?? 'N/A',
                                                        style: const TextStyle(
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
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Popular Clubs and Community Title
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Text(
                        'Popular Clubs & Communities',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    
                    // Clubs and Communities Section - Fetch from Firebase
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('clubs')
                          .orderBy('createdAt', descending: true)
                          .limit(3)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading clubs'));
                        }
                        
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No clubs found'));
                        }
                        
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final clubData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                            final clubId = snapshot.data!.docs[index].id;
                            
                            return GestureDetector(
                              onTap: () {
                                print("[LOG CommunityDetail] ========= Navigating to community detail: $clubId");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunityDetail(
                                      id: clubId,
                                      clubData: clubData,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                height: 130,
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
                                              height: 130,
                                              width: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  height: 130,
                                                  width: 120,
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
                                              height: 130,
                                              width: 120,
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
                                                
                                                const SizedBox(height: 1),
                                                
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
                                                    const SizedBox(width: 2),
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
                                                    // Navigate to club details page
                                                    print("[LOG CommunityDetail] ========= Navigating to community detail from button: $clubId");
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => CommunityDetail(
                                                          id: clubId,
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
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedMapBackground extends StatefulWidget {
  @override
  _AnimatedMapBackgroundState createState() => _AnimatedMapBackgroundState();
}

class _AnimatedMapBackgroundState extends State<_AnimatedMapBackground> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Create an animation controller that repeats indefinitely
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    
    // Create a tween animation from 1.0 to 1.2 (20% zoom)
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    print("[LOG MapAnimation] ========= Map background animation initialized");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Image.asset(
            'assets/images/map_image.png',
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
