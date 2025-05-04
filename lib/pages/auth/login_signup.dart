import 'dart:developer';

import 'package:aastu_map/core/bloc/auth_bloc.dart';
import 'package:aastu_map/core/bloc/auth_event.dart';
import 'package:aastu_map/core/bloc/auth_state.dart';
import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/pages/auth/login_screen.dart';
import 'package:aastu_map/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginSignup extends StatelessWidget {
  const LoginSignup({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/signup_bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Top logo section with Spacer to push content to bottom
              const Spacer(),
              
              // Logo and app title with shadow for visibility
              Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    padding: const EdgeInsets.all(5),
                    // decoration: BoxDecoration(
                    //   color: Colors.white.withOpacity(0.15),
                    //   shape: BoxShape.circle,
                    // ),
                    child: Image.asset(
                      'assets/images/logo_quality_transparent.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'AASTU MAP',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Campus Tour & Guide App',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Bottom buttons section with gradient overlay
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.0),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Login/Signup Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Login / Sign Up',
                        style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Google Sign In Button
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) {
                        // Only rebuild for states related to Google sign-in
                        return (current is AuthLoading && previous is! AuthLoading) ||
                               (current is! AuthLoading && previous is AuthLoading) ||
                               (current is AuthError);
                      },
                      builder: (context, state) {
                        final bool isGoogleLoading = state is AuthLoading;
                        return ElevatedButton.icon(
                          onPressed: isGoogleLoading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(SignInWithGoogleEvent());
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFE8ECF4), width: 1.5),
                            ),
                            elevation: 2,
                          ),
                          icon: isGoogleLoading
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2),
                                  child: const CircularProgressIndicator(
                                    color: Colors.black45,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.asset(
                                    'assets/images/google_icon.png',
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                          label: Text(
                            isGoogleLoading ? "Signing in..." : "Continue with Google",
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Guest Mode Button
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) {
                        // Only rebuild for states related to anonymous sign-in
                        final bool isAnonymousSignIn = 
                            context.read<AuthBloc>().state is AuthLoading && 
                            previous is! AuthLoading;
                        return isAnonymousSignIn || 
                               (current is! AuthLoading && previous is AuthLoading) ||
                               (current is AuthError);
                      },
                      builder: (context, state) {
                        // Track if we're specifically in anonymous sign-in process
                        final bool isAnonymousLoading = 
                            state is AuthLoading && 
                            !(context.read<AuthBloc>().state is AuthLoading && 
                              state is! AuthLoading);
                            
                        return ElevatedButton.icon(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(SignInAnonymously());
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Colors.white, width: 1.5),
                            ),
                            elevation: 0,
                          ),
                          icon: isAnonymousLoading
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.person_outline,
                                  size: 24,
                                ),
                          label: Text(
                            isAnonymousLoading
                                ? "Please wait..."
                                : "Continue as Guest",
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Global BlocListener for navigation after successful authentication
                    BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthAuthenticated) {
                          GoRouter.of(context).go("/home");
                        } else if (state is AuthError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const SizedBox.shrink(), // Empty widget, just for the listener
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
