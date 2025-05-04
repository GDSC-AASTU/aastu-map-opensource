import 'package:aastu_map/core/bloc/auth_bloc.dart';
import 'package:aastu_map/core/bloc/auth_event.dart';
import 'package:aastu_map/core/bloc/auth_state.dart';
import 'package:aastu_map/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double imageHeight = screenHeight * 0.34;
    final double borderRadius = 16.0; // Consistent border radius
    final double inputHeight = 56.0; // Standard input height

    return Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSignupSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Let's verify you first!"),
            backgroundColor: Colors.green,
          ));

          context.go('/verify');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ));
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return SingleChildScrollView(
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
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            'AASTU MAP',
                            style: GoogleFonts.lato(
                              color: Color(0xFFDEBE46),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Create your account',
                            style: GoogleFonts.lato(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        
                        // First Name Field
                        SizedBox(
                          height: inputHeight,
                          child: TextField(
                            controller: _firstnameController,
                            decoration: InputDecoration(
                              hintText: 'First Name',
                              hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                              labelText: 'First Name',
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
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Last Name Field
                        SizedBox(
                          height: inputHeight,
                          child: TextField(
                            controller: _lastnameController,
                            decoration: InputDecoration(
                              hintText: 'Last Name',
                              hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                              labelText: 'Last Name',
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
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Email Field
                        SizedBox(
                          height: inputHeight,
                          child: TextField(
                            controller: _emailController,
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
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Phone Field
                        SizedBox(
                          height: inputHeight,
                          child: TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: 'Phone Number (Optional)',
                              hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                              labelText: 'Phone Number (Optional)',
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
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Password Field
                        SizedBox(
                          height: inputHeight,
                          child: TextField(
                            controller: _passwordController,
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
                            style: const TextStyle(
                              fontSize: 18, // Larger text for password input
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        
                        // Sign Up Button
                        SizedBox(
                          height: inputHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              String firstname = _firstnameController.text.trim();
                              String lastname = _lastnameController.text.trim();
                              String email = _emailController.text.trim();
                              String password = _passwordController.text;
                              String phoneNumber = _phoneController.text.trim();

                              if (firstname.isEmpty || lastname.isEmpty || email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please fill all required fields"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              context.read<AuthBloc>().add(
                                    SignUpEvent(
                                      email: email,
                                      password: password,
                                      firstname: firstname,
                                      lastname: lastname,
                                      phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
                                    ),
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFDEBE46),
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
                                    'Sign Up',
                                    style: GoogleFonts.urbanist(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 20),
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
                        SizedBox(height: 20),
                        
                        // Google Sign Up Button
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
                        SizedBox(height: 20),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account?",
                                  style: GoogleFonts.urbanist()),
                              TextButton(
                                onPressed: () {
                                  GoRouter.of(context).go('/login');
                                },
                                child: Text(
                                  'Login Here',
                                  style: GoogleFonts.urbanist(
                                      color: Color(0xFFDEBE46)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ));
  }
}

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   bool _isSigningUp = false;

//   final FirebaseAuthService _auth = FirebaseAuthService();

//   TextEditingController _firstnameController = TextEditingController();
//   TextEditingController _lastnameController = TextEditingController();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
    
//   }

//   // ignore: non_constant_identifier_names
//   void _SignUp() async {
//     setState(() {
//       _isSigningUp = true;
//     });

//     String firstname = _firstnameController.text.trim();
//     String lastname = _lastnameController.text.trim();
//     String email = _emailController.text.trim();
//     String password = _passwordController.text;

//     User? user = await _auth.signUpWithEmailAndPassword(email, password);

//     setState(() {
//       _isSigningUp = false;
//     });

//     if (user != null) {
//       Fluttertoast.showToast(
//           msg:
//               'User successfully created, you will receive email verification soon');
//       user.sendEmailVerification();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => VerificationPage()),
//       );
//     } else {
//       Fluttertoast.showToast(msg: 'Some error happened');
//       return;
//     }

//     addUserDetails(firstname, lastname, email, user);
//   }

//   Future addUserDetails(
//       String firstname, String lastname, String email, User? user) async {
//     await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
//       'id': user.uid,
//       'firstname': firstname,
//       'lastname': lastname,
//       'email': email,
//       'profilepic':
//           'https://th.bing.com/th/id/OIP.wKJRMskw7LFsAKtcKbu2dQAAAA?rs=1&pid=ImgDetMain'
//     });
//   }
// }
