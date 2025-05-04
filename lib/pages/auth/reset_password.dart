import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});
  final _form_key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    FirebaseAuth auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              GoRouter.of(context).go("/login");
            },
            icon: const Icon(Icons.close)),
        title: const Text(
          'Reset Password',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _form_key,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Column(
            children: [
              const Gap(91),
              TextFormField(
                  controller: email,
                  decoration: const InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter your Email';
                    }
                    return null;
                  }),
              const Gap(30),
              InkWell(
                onTap: () async {
                  if (_form_key.currentState!.validate()) {
                    if (email.text.endsWith('@gmail.com')) {
                      auth
                          .sendPasswordResetEmail(email: email.text.toString())
                          .then(
                        (value) {
                          Fluttertoast.showToast(
                            msg:
                                'We have send you an email to ${email.text.toString()} please check you inbox',
                            backgroundColor: Colors.green,
                            gravity: ToastGravity.BOTTOM,
                          );
                          GoRouter.of(context).go("/login");
                        },
                      ).onError(
                        (error, stackTrace) {
                          Fluttertoast.showToast(
                            msg: error.toString(),
                            backgroundColor: Colors.red,
                            gravity: ToastGravity.BOTTOM,
                          );
                        },
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Email format is wrong',
                        backgroundColor: Colors.red,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  }
                },
                child: Container(
                  height: 51,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFDEBE46),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Center(
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
