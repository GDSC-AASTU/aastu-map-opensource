// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController textcont;
  final TextInputType? keyboardType;

  CustomTextField({
    required this.hintText, 
    required this.textcont,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: TextField(
          controller: textcont,
          keyboardType: keyboardType ?? TextInputType.text,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFFCCCCCC),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xffE8ECF4),
                width: 2, // Adjusted the width to be more reasonable
                style: BorderStyle.solid,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xffE8ECF4),
                width: 2, // Adjusted the width to be more reasonable
                style: BorderStyle.solid,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xffE8ECF4),
                width: 2, // Adjusted the width to be more reasonable
                style: BorderStyle.solid,
              ),
            ),
            filled: true,
            fillColor: const Color(0x99F7F8F9),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
          style: const TextStyle(color: Color(0xFF7E7E7E)),
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController passcont;

  PasswordField({required this.passcont});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: TextField(
        controller: widget.passcont,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: '**********',
          hintStyle: const TextStyle(
            color: Color(0xFFCCCCCC),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Color(0xffE8ECF4),
              width: 2, // Adjusted the width to be more reasonable
              style: BorderStyle.solid,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Color(0xffE8ECF4),
              width: 2, // Adjusted the width to be more reasonable
              style: BorderStyle.solid,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Color(0xffE8ECF4),
              width: 2, // Adjusted the width to be more reasonable
              style: BorderStyle.solid,
            ),
          ),
          filled: true,
          fillColor: const Color(0x99F7F8F9),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Ionicons.eye_outline : Ionicons.eye_off_outline,
              color: const Color(0xFF7E7E7E), // Use a visible color
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
        style: const TextStyle(color: Color(0xFF7E7E7E)),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  bool isLoading;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  CustomButton({
    required this.text,
    this.isLoading = false,
    required this.onPressed,
    required this.color,
    required this.textColor, required RoundedRectangleBorder shape,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : Text(
                text,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
              ),
      ),
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final String iconAsset;
  final String text;
  final VoidCallback onPressed;

  SocialLoginButton(
      {required this.iconAsset, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF7E7E7E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Color(0xFF0F699B), width: 0.5), // Thin line
            // No shadow
          ),
        ),
        icon: Image.asset(iconAsset, height: 24),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
