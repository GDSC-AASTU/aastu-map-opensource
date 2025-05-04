import 'dart:io' show Directory;

import 'package:aastu_map/core/bloc/auth_bloc.dart';
import 'package:aastu_map/core/bloc/auth_event.dart';
import 'package:aastu_map/core/bloc/auth_state.dart';
import 'package:aastu_map/core/bloc/community_bloc.dart';
import 'package:aastu_map/core/bloc/profile_bloc.dart';
import 'package:aastu_map/data/datasources/authentication_api.dart';
import 'package:aastu_map/data/datasources/community_local_data_source.dart';
import 'package:aastu_map/data/datasources/community_remote_data_source.dart';
import 'package:aastu_map/data/models/club_model.dart';
import 'package:aastu_map/data/repository/get_all_community.dart';
import 'package:aastu_map/data/repository/repository.dart';
import 'package:aastu_map/data/repositories/auth_repository.dart';
import 'package:aastu_map/firebase_options.dart';
import 'package:aastu_map/helpers/page_routes.dart';
import 'package:aastu_map/pages/discover/search_history_model.dart';
import 'package:aastu_map/pages/discover/search_history_service.dart';
import 'package:aastu_map/pages/home_page/main_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(SearchHistoryItemAdapter());
  await Hive.openBox<SearchHistoryItem>('searchHistory');

  // Initialize search history listener
  SearchHistoryService.setupListener();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[DeviceOrientation.portraitUp],
  );

  if (kIsWeb) {
    // await FirebaseAppCheck.instance.activate(webProvider: ReCaptchaV3Provider(siteKey: 'recaptcha-v3-site-key'));
  } else if (!kReleaseMode) {
    await FirebaseAppCheck.instance
        .activate(androidProvider: AndroidProvider.debug);
  } else {
    await FirebaseAppCheck.instance
        .activate(androidProvider: AndroidProvider.playIntegrity);
  }

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    _subscribeToNotificationTopics();
  }

  void _subscribeToNotificationTopics() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Subscribe to the 'all_users' topic
    await messaging.subscribeToTopic('all_users');

    // Get the current user's ID
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;

      // Subscribe to the 'user_$userId' topic
      await messaging.subscribeToTopic('user_$userId');
    } else {
      print('[LOG Notifications] ========= User is not logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    var fireauth = FirebaseAuth.instance;
    var google = GoogleSignIn();
    var authrepo =
        AuthenticationRepository(firebaseAuth: fireauth, googleSignIn: google);
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              AuthRepository(),
            )..add(CheckAuthStatusEvent()),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) =>
                ProfileBloc(profileRepository: ProfileRepository()),
          ),
          BlocProvider(
              create: (context) => CommunityBloc(
                  getAllCommunities: GetAllCommunity(
                      localDataSource: CommunityLocalDataSource(),
                      remoteDataSource: CommunityRemoteDataSource()))
                ..add(GetAllCommunitiesEvent()))
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // For initial navigation based on auth state
            if (state is AuthInitial || state is AuthLoading) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'AASTU Map',
                theme: _buildAppTheme(),
                home: const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            } else if (state is AuthAuthenticated) {
              // User is authenticated, show MainScreen
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'AASTU Map',
                theme: _buildAppTheme(),
                home: const MainScreen(),
              );
            } else {
              // For login, signup, etc. use router
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'AASTU Map',
                theme: _buildAppTheme(),
                routerConfig: routerDelegate,
              );
            }
          },
        ));
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange[800]!),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
      ),
      textTheme: GoogleFonts.urbanistTextTheme(),
      fontFamily: 'Montserrat',
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(
      '[LOG Background] ========= Handling a background message: ${message.messageId}');
}
