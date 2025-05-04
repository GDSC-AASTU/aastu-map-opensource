import 'package:aastu_map/pages/auth/login_signup.dart';
import 'package:aastu_map/pages/auth/verification_success.dart';
import 'package:aastu_map/pages/auth/verify_email_screen.dart';
import 'package:aastu_map/pages/community/community.dart';
import 'package:aastu_map/pages/home_page/home_screen.dart';
import 'package:aastu_map/pages/home_page/main_screen.dart';
import 'package:aastu_map/pages/on_boarding/onboarding_screen.dart';
import 'package:aastu_map/pages/on_boarding/splash.dart';
import 'package:aastu_map/pages/community/community_detail.dart';
import 'package:aastu_map/pages/auth/reset_password.dart';
import 'package:aastu_map/pages/places/panorama_view.dart';
import 'package:aastu_map/pages/places/places.dart';
import 'package:aastu_map/pages/profile/edit_profile.dart';
import 'package:aastu_map/pages/profile/profile.dart';
import 'package:aastu_map/pages/auth/login_screen.dart';
import 'package:aastu_map/pages/auth/signup_screen.dart';
import 'package:aastu_map/pages/full_map/full_map_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aastu_map/pages/places/place_detail.dart';
import 'package:aastu_map/pages/admin/create_content.dart';
import 'package:aastu_map/pages/admin/places/places_admin.dart';
import 'package:aastu_map/pages/admin/clubs/clubs_admin.dart';
import 'package:aastu_map/pages/admin/about/about_admin.dart';
import 'package:aastu_map/pages/admin/developers/developers_admin.dart';
import 'package:aastu_map/pages/admin/events/events_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aastu_map/pages/discover/discover_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _sectionANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionANav');

final routerDelegate = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) => SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) => OnboardingPage(),
    ),
    GoRoute(
      path: '/full_map',
      builder: (BuildContext context, GoRouterState state) => FullMapPage(),
    ),
    GoRoute(
      path: "/places/:imageUrl",
      builder: (BuildContext context, GoRouterState state) {
        final encodedImageUrl = state.pathParameters['imageUrl'];
        final imageUrl = Uri.decodeComponent(encodedImageUrl!);
        return PanoramaView(imageUrl: imageUrl);
      },
    ),
    GoRoute(
      path: '/detail_page/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        final String id = state.pathParameters['id']!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('places').doc(id).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Scaffold(
                body: Center(
                  child: Text('Place not found'),
                ),
              );
            }

            final placeData = snapshot.data!.data() as Map<String, dynamic>;
            return PlaceDetail(
              id: id,
              place: placeData,
            );
          },
        );
      },
    ),
    GoRoute(
      path: "/community_detail/:id",
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        final String id = state.pathParameters['id']!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('clubs').doc(id).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Scaffold(
                body: Center(
                  child: Text('Club not found'),
                ),
              );
            }

            final clubData = snapshot.data!.data() as Map<String, dynamic>;
            return CommunityDetail(
              id: id,
              clubData: clubData,
            );
          },
        );
      },
    ),
    // Admin routes
    GoRoute(
      path: '/admin/create_content',
      builder: (BuildContext context, GoRouterState state) =>
          const CreateContentPage(),
    ),
    GoRoute(
      path: '/admin/places',
      builder: (BuildContext context, GoRouterState state) =>
          const PlacesAdminPage(),
    ),
    GoRoute(
      path: '/admin/clubs',
      builder: (BuildContext context, GoRouterState state) =>
          const ClubsAdminPage(),
    ),
    GoRoute(
      path: '/admin/about_aastu',
      builder: (BuildContext context, GoRouterState state) =>
          const AboutAdminPage(),
    ),
    GoRoute(
      path: '/admin/developers',
      builder: (BuildContext context, GoRouterState state) =>
          const DevelopersAdmin(),
    ),
    GoRoute(
      path: '/admin/events',
      builder: (BuildContext context, GoRouterState state) =>
          const EventsAdminPage(),
    ),
    GoRoute(
      path: '/main',
      builder: (BuildContext context, GoRouterState state) {
        return const MainScreen();
      },
    ),
    // Individual routes for direct access
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) => HomePage(),
    ),
    GoRoute(
      path: '/places',
      builder: (BuildContext context, GoRouterState state) => const Places(),
    ),
    GoRoute(
      path: '/community',
      builder: (BuildContext context, GoRouterState state) => const Community(),
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) => const Profile(),
      routes: [
        GoRoute(
          path: 'editprofile', // Nested under /profile
          builder: (BuildContext context, GoRouterState state) => EditProfile(),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => LoginPage(),
    ),
    GoRoute(
      path: '/login-signup',
      builder: (BuildContext context, GoRouterState state) => LoginSignup(),
    ),

    GoRoute(
      path: '/signup',
      builder: (BuildContext context, GoRouterState state) => SignUpPage(),
    ),
    GoRoute(
      path: '/verify',
      builder: (BuildContext context, GoRouterState state) =>
          VerifyEmailScreen(),
    ),
    GoRoute(
      path: '/success',
      builder: (BuildContext context, GoRouterState state) =>
          VerificationSuccessPage(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (BuildContext context, GoRouterState state) => ChangePassword(),
    ),
    // Discover page route with root navigator
    GoRoute(
      path: '/discover',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (BuildContext context, GoRouterState state) {
        return const DiscoverPage();
      },
    ),
  ],
);
