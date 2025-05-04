import 'package:aastu_map/core/bloc/auth_bloc.dart';
import 'package:aastu_map/core/bloc/auth_event.dart';
import 'package:aastu_map/core/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => {context.go("/login")},
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: BlocListener<AuthBloc, AuthState>(listener: (context, state) {
          if (state is EmailVerificationSuccess) {
            // Navigate to the success screen
            GoRouter.of(context).go("/success");
          } else if (state is EmailVerificationFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is EmailVerificationSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Verification email sent.")),
            );
          }
        }, child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          BlocProvider.of<AuthBloc>(context).add(
            StartEmailVerificationCheckEvent(),
          );
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.mark_email_read_rounded,
                    size: 70,
                    color: Color.fromARGB(255, 218, 181, 0),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Confirm e-mail",
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    email ?? '****@gmail.com',
                    style: Theme.of(context).textTheme.labelLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Verify your email to continue using our app",
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Color(0xFFDEBE46)),
                      ),
                      onPressed: () => {
                        BlocProvider.of<AuthBloc>(context).add(
                          ManuallyCheckEmailVerificationEvent(),
                        )
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => BlocProvider.of<AuthBloc>(context).add(
                        SendEmailVerificationEvent(),
                      ),
                      child: const Text("Resend"),
                    ),
                  )
                ],
              ),
            ),
          );
        })));
  }
}
