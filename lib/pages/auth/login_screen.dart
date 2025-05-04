import 'package:aastu_map/core/bloc/auth_bloc.dart';
import 'package:aastu_map/core/bloc/auth_event.dart';
import 'package:aastu_map/core/bloc/auth_state.dart';
import 'package:aastu_map/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoginAttempted = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (!_isLoginAttempted) return null;
    
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (!_isLoginAttempted) return null;
    
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double imageHeight = screenHeight * 0.34;
    final double borderRadius = 16.0; // Consistent border radius
    final double inputHeight = 56.0; // Standard input height

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to the home screen
          GoRouter.of(context).go("/home");
          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //   content: Text("Welcome back!"),
          //   backgroundColor: Colors.green,
          // ));
        } else if (state is AuthUnverified) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Your email is not verified yet.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFFDEBE46),
          ));

          context.go('/verify');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }, 
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    height: imageHeight,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/aastu.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: imageHeight - 50),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, -3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                'AASTU MAP',
                                style: GoogleFonts.lato(
                                  color: const Color(0xFFDEBE46),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Welcome back',
                                style: GoogleFonts.lato(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: inputHeight,
                              child: TextFormField(
                                controller: _email,
                                decoration: InputDecoration(
                                  hintText: 'johndoe@gmail.com',
                                  hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    borderSide: const BorderSide(color: Color(0xFFE8ECF4), width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    borderSide: const BorderSide(color: Color(0xFFDEBE46), width: 1.5),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0x99F7F8F9),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: inputHeight,
                              child: TextFormField(
                                controller: _password,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFFCCCCCC),
                                    fontSize: 18, // Larger dots for password
                                  ),
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    borderSide: const BorderSide(color: Color(0xFFE8ECF4), width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    borderSide: const BorderSide(color: Color(0xFFDEBE46), width: 1.5),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0x99F7F8F9),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: const Color(0xFF7E7E7E),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: _validatePassword,
                                style: const TextStyle(
                                  fontSize: 18, // Larger text for password input
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  GoRouter.of(context).go("/reset-password");
                                },
                                child: Text(
                                  'Forget Password?',
                                  style: GoogleFonts.urbanist(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF7E7E7E),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: inputHeight,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoginAttempted = true;
                                  });
                                  
                                  if (_formKey.currentState!.validate()) {
                                    String email = _email.text.trim();
                                    String password = _password.text;
                                    context.read<AuthBloc>().add(
                                      LoginEvent(email: email, password: password),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDEBE46),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                  ),
                                ),
                                child: state is AuthLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: GoogleFonts.urbanist(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              children: [
                                Expanded(child: Divider(color: Colors.black26)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('or'),
                                ),
                                Expanded(child: Divider(color: Colors.black26)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: inputHeight,
                              child: ElevatedButton.icon(
                                icon: Image.asset('assets/images/google_icon.png', height: 24),
                                label: Text(
                                  'Continue with Google',
                                  style: GoogleFonts.urbanist(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    SignInWithGoogleEvent(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    side: const BorderSide(color: Color(0xFFE8ECF4), width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Don't have an account?",
                                      style: GoogleFonts.urbanist()),
                                  TextButton(
                                    onPressed: () {
                                      GoRouter.of(context).go('/signup');
                                    },
                                    child: Text(
                                      'Register Now',
                                      style: GoogleFonts.urbanist(
                                          color: const Color(0xFFDEBE46)),
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
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
