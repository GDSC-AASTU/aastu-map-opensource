import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Stack(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFFAF8D0E),
                      size: 100,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 70),
              Text(
                'E-mail Verified',
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 10, 10, 50),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Congratulations, your e-mail has been verified. You can start using the app',
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 80),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFFAF8D0E), // Custom golden color for the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                ),
                onPressed: () {
                  Confetti.launch(context,
                      options: const ConfettiOptions(
                          colors: [Colors.yellow],
                          particleCount: 100,
                          spread: 70,
                          y: 0.6));
                  GoRouter.of(context).go("/home");
                },
                child: Text(
                  'CONTINUE',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
