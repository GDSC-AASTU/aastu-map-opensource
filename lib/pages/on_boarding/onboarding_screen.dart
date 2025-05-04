import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/pages/auth/login_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatefulWidget {
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(bottom: 80),
          child: PageView(
            controller: controller,
            onPageChanged: (index) => {setState(() => isLastPage = index == 2)},
            children: [
              buildPage(
                imageUrl: 'assets/anim/onboarding_2.json',
                title: 'Welcome to AASTU  Map',
                subtitle: 'Navigate campus easily with our interactive map',
                controller: controller,
              ),
              buildPage(
                imageUrl: 'assets/anim/onboarding_3.json',
                title: 'Navigate with Confidence',
                subtitle:
                    'Get step-by-step navigation to your class, meeting, or event',
                controller: controller,
              ),
              buildPage(
                imageUrl: 'assets/anim/onboarding_1.json',
                title: 'Discover Points of Interest',
                subtitle:
                    'Discover AASTU\'s highlights: buildings, dining, libraries, sports, and more',
                controller: controller,
              )
            ],
          ),
        ),
      ),
      bottomSheet: isLastPage
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => controller.previousPage(
                      duration: Duration(
                          milliseconds: 300), // Duration for the transition
                      curve: Curves
                          .easeInOut, // Animation curve for the transition
                    ),
                    child: Text(
                      'Back',
                      style: GoogleFonts.inter(
                        color: AppColors.secondary_grey_for_text,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginSignup(),
                        ),
                      );
                    },
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => controller.previousPage(
                      duration: Duration(
                          milliseconds: 300), // Duration for the transition
                      curve: Curves
                          .easeInOut, // Animation curve for the transition
                    ),
                    child: Text(
                      'Back',
                      style: GoogleFonts.inter(
                        color: AppColors.secondary_grey_for_text,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

Widget buildPage({
  required String imageUrl,
  required String title,
  required String subtitle,
  required PageController controller,
}) =>
    Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          SizedBox(
              height: 350,
              width: double.infinity,
              child: Lottie.asset(imageUrl)),
          const SizedBox(height: 5),
          SmoothPageIndicator(
            controller: controller,
            count: 3,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 16,
              expansionFactor: 1.5,
              activeDotColor: AppColors.primary,
            ),
            onDotClicked: (index) => controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: AppColors.grey_for_text,
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              // maxLines: 3,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
