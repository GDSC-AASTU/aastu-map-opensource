import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aastu_map/core/colors.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aastu_map/core/bloc/profile_bloc.dart';
import 'package:aastu_map/core/bloc/profile_event.dart';
import 'package:aastu_map/core/bloc/profile_state.dart';
import 'package:aastu_map/pages/chat/api_config.dart';
import 'package:aastu_map/pages/chat/chat_screen.dart';
import 'package:aastu_map/pages/home_page/home_screen.dart';
import 'package:aastu_map/pages/places/places.dart';
import 'package:aastu_map/pages/community/community.dart';
import 'package:aastu_map/pages/profile/profile.dart';
import 'package:line_icons/line_icons.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // List of screens for the bottom navigation
  final List<Widget> _screens = [
    HomePage(),
    const Places(),
    const Community(),
    const Profile(),
  ];

  @override
  void initState() {
    super.initState();
    // Set status bar style for all tabs
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    
    _pageController.addListener(() {
      if (_pageController.page?.round() != _selectedIndex) {
        setState(() {
          _selectedIndex = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Load profile data when building the main screen
    context.read<ProfileBloc>().add(LoadProfileEvent());
    
    final isHomeRoute = _selectedIndex == 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swiping
          children: _screens,
        ),

        floatingActionButton: isHomeRoute ? FloatingActionButton(
          backgroundColor: AppColors.primary,
          elevation: 8,
          onPressed: () {
            // Navigate to AI Assistant chat
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ChatScreen(
                  apiKey: ApiConfig.openAIApiKey,
                ),
              ),
            );
          },
          child: const Icon(
            LineIcons.robot,
            color: Colors.white,
            size: 30,
          ),
        ) : null,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: Colors.white,
                iconSize: 24,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: AppColors.primary,
                color: Colors.black,
                tabBorderRadius: 30,
                tabs: const [
                  GButton(
                    icon: LineIcons.home,
                    text: 'Home',
                    backgroundColor: AppColors.primary,
                  ),
                  GButton(
                    icon: LineIcons.mapMarker,
                    text: 'Places',
                    backgroundColor: AppColors.primary,
                  ),
                  GButton(
                    icon: LineIcons.users,
                    text: 'Community',
                    backgroundColor: AppColors.primary,
                  ),
                  GButton(
                    icon: LineIcons.user,
                    text: 'Profile',
                    backgroundColor: AppColors.primary,
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  if (index != _selectedIndex) {
                    setState(() {
                      _selectedIndex = index;
                      _pageController.jumpToPage(index);
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
